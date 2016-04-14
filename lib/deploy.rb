require 'rubygems'
require 'bundler'
Bundler.setup

require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'time'

## DeployHQ Ruby API Client
## This is a ruby API library for the DeployHQ deployment platform.

require 'deploy/errors'
require 'deploy/request'
require 'deploy/base'

require 'deploy/project'
require 'deploy/deployment'
require 'deploy/deployment_tap'
require 'deploy/deployment_status_poll'
require 'deploy/server'
require 'deploy/server_group'


module Deploy
  class << self
    ## Domain which you wish to access (e.g. atech.deployhq.com)
    attr_accessor :site
    ## E-Mail address you wish to authenticate with
    attr_accessor :email
    ## API key for the user you wish to authenticate with
    attr_accessor :api_key
  end
end
