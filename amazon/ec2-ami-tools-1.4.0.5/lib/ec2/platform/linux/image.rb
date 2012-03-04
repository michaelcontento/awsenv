# Copyright 2008-2009 Amazon.com, Inc. or its affiliates.  All Rights
# Reserved.  Licensed under the Amazon Software License (the
# "License").  You may not use this file except in compliance with the
# License. A copy of the License is located at
# http://aws.amazon.com/asl or in the "license" file accompanying this
# file.  This file is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See
# the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'ec2/oem/open4'
require 'ec2/amitools/fileutil'
require 'ec2/amitools/syschecks'
require 'ec2/amitools/exception'
require 'ec2/platform/linux/mtab'
require 'ec2/platform/linux/fstab'
require 'ec2/platform/linux/constants'

module EC2
  module Platform
    module Linux
      
      # This class encapsulate functionality to create an file loopback image
      # from a volume. The image is created using dd. Sub-directories of the 
      # volume, including mounts of local filesystems, are copied to the image. 
      # Symbolic links are preserved.      
      class Image
        IMG_MNT = '/mnt/img-mnt'
        EXCLUDES= ['/dev', '/media', '/mnt', '/proc', '/sys']
        DEFAULT_FSTAB = EC2::Platform::Linux::Fstab::DEFAULT      
        LEGACY_FSTAB  = EC2::Platform::Linux::Fstab::LEGACY
      
        #---------------------------------------------------------------------#
        
        # Initialize the instance with the required parameters.
        # * _volume_ The path to the volume to create the image file from.
        # * _image_filename_ The name of the image file to create.
        # * _mb_image_size_ The image file size in MB.
        # * _exclude_ List of directories to exclude.
        # * _debug_ Make extra noise.
        def initialize( volume,
                        image_filename,
                        mb_image_size,
                        exclude,
                        includes,
                        filter = true,
                        fstab = nil,
                        debug = false )
          @volume = volume
          @image_filename = image_filename
          @mb_image_size = mb_image_size
          @exclude = exclude
          @includes = includes
          @filter = filter
          @fstab = nil
          # Cunning plan or horrible hack?
          # If :legacy is passed in as the fstab, we use the old v3 manifest's
          # device naming and fstab.
          if [:legacy, :default].include? fstab
            @fstab = fstab
          elsif not fstab.nil?
            @fstab = File.open(fstab).read()
          end
          @debug = debug
          
          # Exclude the temporary image mount point if it is under the volume
          # being bundled.
          if IMG_MNT.index( volume ) == 0
            @exclude << IMG_MNT
          end
        end
      
        #--------------------------------------------------------------------#
        
        # Create the loopback image file and copy volume to it.
        def make
          begin
            puts( "Copying #{@volume} into the image file #{@image_filename}...")
            puts( 'Excluding: ' )
            @exclude.each { |x| puts( "\t #{x}" ) }
            
            create_image_file
            format_image
            execute( 'sync' )  # Flush so newly formatted filesystem is ready to mount.
            mount_image
            make_special_dirs
            copy_rec( @volume, IMG_MNT)
            update_fstab
          ensure
            cleanup
          end
        end
        
        private
        
        #---------------------------------------------------------------------#
        
        def unmount(mpoint)
          if mounted?(mpoint) then
              execute('umount -d ' + mpoint)
          end
        end
      
        #---------------------------------------------------------------------#
      
        def mounted?(mpoint)
          EC2::Platform::Linux::Mtab.load.entries.keys.include? mpoint
        end
      
        #---------------------------------------------------------------------#
      
        # Unmount devices. Delete temporary files.
        def cleanup
          # Unmount image file.
          unmount(IMG_MNT)
        end
        
        #---------------------------------------------------------------------#
      
        # Call dd to create the image file.
        def create_image_file
          cmd = "dd if=/dev/zero of=" + @image_filename + " bs=1M count=1 seek=" + 
            (@mb_image_size-1).to_s
          execute( cmd )
        end
        
        #---------------------------------------------------------------------#
        
        # Format the image file, tune filesystem not to fsck based on interval.
        # Where available and possible, retain the original root volume label
        # uuid and file-system type falling back to using ext3 if not sure of
        # what to do.
        def format_image
          mtab = EC2::Platform::Linux::Mtab.load
          root = mtab.entries[@volume].device rescue nil
          info = fsinfo( root )
          label= info[:label]
          uuid = info[:uuid]
          type = info[:type] || 'ext3'

          tune = nil
          mkfs = [ '/sbin/mkfs.' + type ]
          case type
          when 'btrfs'
            mkfs << [ '-L', label] if !label.to_s.empty?
            mkfs << [ @image_filename ]
          when 'xfs'
            mkfs << [ '-L', label] if !label.to_s.empty?
            mkfs << [ @image_filename ]
            tune =  [ '/usr/sbin/xfs_admin' ]
            tune << [ '-U', uuid ] if uuid
            tune << [ @image_filename ]
          else
            # type unknown or ext2 or ext3 or ext4
            mkfs << [ '-L', label] if !label.to_s.empty?
            mkfs << [ '-F', @image_filename ]   
            tune =  [ '/sbin/tune2fs -i 0' ]
            tune << [ '-U', uuid ] if uuid
            tune << [ @image_filename ]
          end
          execute( mkfs.join( ' ' ) )
          execute( tune.join( ' ' ) ) if tune
        end

        def fsinfo( fs )
          result = {}
          if fs and File.exists?( fs )
            ['LABEL', 'UUID', 'TYPE' ].each do |tag|
              begin
                property = tag.downcase.to_sym
                value = evaluate( '/sbin/blkid -o value -s %s %s' % [tag, fs] ).strip
                result[property] = value if value and not value.empty?
              rescue FatalError => e
                if @debug
                  STDERR.puts e.message
                  STDERR.puts "Could not replicate file system #{property}. Proceeding..."
                end
              end
            end
          end
          result
        end

        #---------------------------------------------------------------------#
        
        # Mount the image file as a loopback device. The mount point is created
        # if necessary.
        def mount_image
          Dir.mkdir(IMG_MNT) if not FileUtil::exists?(IMG_MNT)
          raise FatalError.new("image already mounted") if mounted?(IMG_MNT)
          execute( 'mount -o loop ' + @image_filename + ' ' + IMG_MNT )
        end
        
        #---------------------------------------------------------------------#      
        # Copy the contents of the specified source directory to the specified
        # target directory, recursing sub-directories. Directories within the
        # exclusion list are not copied. Symlinks are retained but not traversed.
        #
        # src: The source directory name.
        # dst: The destination directory name.
        # options: A set of options to try.
        def copy_rec( src, dst, options={:xattributes => true} )
          begin
            rsync = EC2::Platform::Linux::Rsync::Command.new
            rsync.archive.times.recursive.sparse.links.quietly.include(@includes).exclude(@exclude)
            if @filter
              rsync.exclude(EC2::Platform::Linux::Constants::Security::FILE_FILTER)
            end
            rsync.xattributes if options[ :xattributes ]
            rsync.src(File::join( src, '*' )).dst(dst)
            execute(rsync.expand)
            return true
          rescue Exception => e
            rc = $?.exitstatus
            return true if rc == 0
            if rc == 23 and SysChecks::rsync_usable?
              STDERR.puts [
               'NOTE: rsync seemed successful but exited with error code 23. This probably means',
               'that your version of rsync was built against a kernel with HAVE_LUTIMES defined,',
               'although the current kernel was not built with this option enabled. The bundling',
               'process will thus ignore the error and continue bundling.  If bundling completes',
               'successfully, your image should be perfectly usable. We, however, recommend that',
               'you install a version of rsync that handles this situation more elegantly.'
              ].join("\n")
              return true
            elsif rc == 1 and options[ :xattributes ]
              STDERR.puts [
               'NOTE: rsync with preservation of extended file attributes failed. Retrying rsync',
               'without attempting to preserve extended file attributes...'
              ].join("\n")
              o = options.clone
              o[ :xattributes ] = false
              return copy_rec( src, dst, o)
            end
            raise e
          end
        end
      
        #----------------------------------------------------------------------------#
      
        def make_special_dirs
          # Make /proc and /sys.
          Dir.mkdir( IMG_MNT + '/mnt' )
          Dir.mkdir( IMG_MNT + '/proc' )
          Dir.mkdir( IMG_MNT + '/sys' )
          
          # Make device nodes.
          dev_dir = IMG_MNT + '/dev'
          Dir.mkdir( dev_dir )
          # MAKEDEV is incredibly variable across distros, so use mknod directly.
          execute("mknod #{dev_dir}/null    c 1 3")
          execute("mknod #{dev_dir}/zero    c 1 5")
          execute("mknod #{dev_dir}/tty     c 5 0")
          execute("mknod #{dev_dir}/console c 5 1")
          execute("ln -s null #{dev_dir}/X0R")
        end
      
        #----------------------------------------------------------------------------#
      
        def make_fstab
          case @fstab
          when :legacy
            return LEGACY_FSTAB
          when :default
            return DEFAULT_FSTAB
          else
            return @fstab
          end
        end
      
        #----------------------------------------------------------------------------#
      
        def update_fstab
          if @fstab
            etc = File::join( IMG_MNT, 'etc')
            fstab = File::join( etc, 'fstab' )
      
            FileUtils::mkdir_p( etc ) unless File::exist?( etc)
            execute( "cp #{fstab} #{fstab}.old" ) if File.exist?( fstab )
            fstab_content = make_fstab
            File.open( fstab, 'w' ) { |f| f.write( fstab_content ) }
            puts "/etc/fstab:"
            fstab_content.each do |s|
              puts "\t #{s}"
            end
          end
        end
      
        #----------------------------------------------------------------------------#
        
        # Execute the command line _cmd_.
        def execute( cmd )
          if @debug
            STDERR.puts( "Executing: #{cmd} " )
            suffix = ''
          else
            suffix = ' 2>&1 > /dev/null'
          end
        raise "execution failed: \"#{cmd}\"" unless system( cmd + suffix )
        end

        #---------------------------------------------------------------------#        
        # Execute command line passed in and return STDOUT output if successful.
        def evaluate( cmd, success = 0, verbattim = nil )
          verbattim = @debug if verbattim.nil?
          STDERR.puts( "Evaluating: '#{cmd}' " ) if verbattim
          pid, stdin, stdout, stderr = Open4::popen4( cmd )
          pid, status = Process::waitpid2 pid
          unless status.exitstatus == success
            raise FatalError.new( "Failed to evaluate '#{cmd }'. Reason: #{stderr.read}." )
          end
          stdout.read
        end
      end
    end
  end
end
