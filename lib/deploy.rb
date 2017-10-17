require 'rubygems'
require 'bundler'

require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'time'

## DeployHQ Ruby API Client
## This is a ruby API library for the DeployHQ deployment platform.

require 'deploy/errors'
require 'deploy/configuration'
require 'deploy/request'
require 'deploy/websocket_client'
require 'deploy/resource'

require 'deploy/resources/project'
require 'deploy/resources/deployment'
require 'deploy/resources/deployment_step'
require 'deploy/resources/deployment_step_log'
require 'deploy/resources/server'
require 'deploy/resources/server_group'

require 'deploy/version'

module Deploy
  class << self
    attr_writer :configuration_file

    def configure
      @configuration ||= Configuration.new
      yield @configuration if block_given?
      @configuration
    end

    def configuration
      @configuration ||= begin
        if File.exist?(configuration_file)
          Configuration.from_file(configuration_file)
        else
          Configuration.new
        end
      end
    end

    def configuration_file
      @configuration_file ||= File.join(Dir.pwd, 'Deployfile')
    end
  end
end
