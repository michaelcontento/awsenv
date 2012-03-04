# Copyright 2008-2009 Amazon.com, Inc. or its affiliates.  All Rights
# Reserved.  Licensed under the Amazon Software License (the
# "License").  You may not use this file except in compliance with the
# License. A copy of the License is located at
# http://aws.amazon.com/asl or in the "license" file accompanying this
# file.  This file is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See
# the License for the specific language governing permissions and
# limitations under the License.

require 'ec2/amitools/bundlemachineparameters'

# The Bundle Volume command line parameters.
class BundleVolParameters < BundleMachineParameters
  
  PREFIX_DESCRIPTION        = "The filename prefix for bundled AMI files. Defaults to \"image\"."
  EXCLUDE_DESCRIPTION       = ["A comma-separated list of absolute directory paths, relative to",
                               "the volume being bundled, to exclude. This option overrides the",
                               "\"--all\" option."]
  INCLUDE_DESCRIPTION       = ["Linux Only. A comma-separated list of absolute file paths, relative to the volume",
                               "being bundled, to include. This option overrides the default filtered",
                               "files list."]
  FILTER_DESCRIPTION        = "Do not use the default filtered files list."
  ALL_DESCRIPTION           = ["Include all directories in the volume being bundled, including those",
                               "on remotely mounted filesystems."]
  SIZE_DESCRIPTION          = ["The size, in MB (1024 * 1024 bytes), of the image file to create.",
                               "The maximum size is 10240 MB."]
  VOLUME_DESCRIPTION        = "The absolute path to the mounted volume to be bundled. Defaults to \"/\"."
  FSTAB_DESCRIPTION         = "The absolute path to the fstab to be bundled into the image."
  GENERATE_FSTAB_DESCRIPTION= ["Inject a generated EC2 fstab. (Only use this if you are not rebundling",
                                "an existing instance.)"]
  INHERIT_DESCRIPTION       = ['Inherit instance metadata. Enabled by default.',
                               'Bundling will fail if inherit is enabled but instance data',
                               'is not accessible, for example not bundling an EC2 instance.']
  
  attr_accessor :all,
                :exclude,
                :includes,
                :filter,
                :prefix,
                :size,
                :volume,
                :fstab,
                :inherit,
                :generate_fstab

  def optional_params()
    super()
    on('-a', '--all', *ALL_DESCRIPTION) do
      @all = true
    end
    
    on('-e', '--exclude DIR1,DIR2,...', Array, *EXCLUDE_DESCRIPTION) do |p|
      @exclude = p
    end

    on('-i', '--include FILE1,FILE2,...', Array, *INCLUDE_DESCRIPTION) do |p|
      @includes = p
    end

    on('--no-filter', FILTER_DESCRIPTION) do
      @filter = false
    end
    
    on('-p', '--prefix PREFIX', String, PREFIX_DESCRIPTION) do |prefix|
      assert_good_key(prefix, '--prefix')
      @prefix = prefix
    end
    
    on('-s', '--size MB', Integer,  *SIZE_DESCRIPTION) do |p|
      @size = p
    end
    
    on('--[no-]inherit', *INHERIT_DESCRIPTION) do |p|
      @inherit = p
    end
    
    on('-v', '--volume PATH', String, VOLUME_DESCRIPTION) do |volume|
      assert_directory_exists(volume, '--volume')
      @volume = volume
    end
    
    on('--fstab PATH', String, FSTAB_DESCRIPTION) do |fstab|
      assert_file_exists(fstab, '--fstab')
      @fstab = fstab
    end
    
    on('--generate-fstab', *GENERATE_FSTAB_DESCRIPTION) do
      @generate_fstab = true
    end
  end

  def validate_params()
    raise InvalidCombination.new("--fstab", "--generate-fstab") if @fstab and @generate_fstab

    if @exclude
      volume = @volume || '/'
      @exclude.each do |dir|
        path = File::join(volume, dir)
        assert_exists(path, '--exclude')
      end
    end

    if @includes
      volume = @volume || '/'
      @includes.each do |file|
        path = File::join(volume, file)
        assert_exists(path, '--include')
      end
    end

    super()
  end

  def set_defaults()
    super()
    @inherit = true if @inherit.nil? # false means a parameter was provided.
    @exclude ||= []
    @includes ||= []
    @filter = true if @filter.nil?
    @prefix ||= 'image'
    @size ||= MAX_SIZE_MB
    @volume ||= '/'
    if @generate_fstab
      @fstab = :default
      @fstab = :legacy if @arch == "i386"
    end
  end
end
