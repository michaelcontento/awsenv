# Copyright 2008-2009 Amazon.com, Inc. or its affiliates.  All Rights
# Reserved.  Licensed under the Amazon Software License (the
# "License").  You may not use this file except in compliance with the
# License. A copy of the License is located at
# http://aws.amazon.com/asl or in the "license" file accompanying this
# file.  This file is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See
# the License for the specific language governing permissions and
# limitations under the License.

require 'ec2/amitools/parameters_base'

#------------------------------------------------------------------------------#

class S3ToolParameters < ParametersBase

  BUCKET_DESCRIPTION = ["The bucket to use. This is an S3 bucket,",
                        "followed by an optional S3 key prefix using '/' as a delimiter."]
  MANIFEST_DESCRIPTION = "The path to the manifest file."
  URL_DESCRIPTION = "The S3 service URL. Defaults to https://s3.amazonaws.com."

  attr_accessor :bucket,
                :keyprefix,
                :user,
                :pass,
                :url

  #------------------------------------------------------------------------------#

  def split_container(container)
    splitbits = container.sub(%r{^/*},'').sub(%r{/*$},'').split("/")
    bucket = splitbits.shift
    keyprefix = splitbits.join("/")
    keyprefix += "/" unless keyprefix.empty?
    @keyprefix = keyprefix
    @bucket = bucket
  end
  
  #----------------------------------------------------------------------------#

  def mandatory_params()
    on('-b', '--bucket BUCKET', String, *BUCKET_DESCRIPTION) do |container|
      @container = container
      split_container(@container)
    end
    
    on('-a', '--access-key USER', String, USER_DESCRIPTION) do |user|
      @user = user
    end
    
    on('-s', '--secret-key PASSWORD', String, PASS_DESCRIPTION) do |pass|
      @pass = pass
    end
  end

  #----------------------------------------------------------------------------#

  def optional_params()
    on('--url URL', String, URL_DESCRIPTION) do |url|
      @url = url
    end
  end

  #----------------------------------------------------------------------------#

  def validate_params()
    raise MissingMandatory.new('--access-key') unless @user
    raise MissingMandatory.new('--secret-key') unless @pass
    raise MissingMandatory.new('--bucket') unless @container
  end

  #----------------------------------------------------------------------------#

  def set_defaults()
    @url ||= 'https://s3.amazonaws.com'
  end

end
