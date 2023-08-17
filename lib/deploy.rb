# frozen_string_literal: true

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

    def configure
      @configuration ||= Configuration.new
      yield @configuration if block_given?
      @configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configuration_file=(file_location)
      @configuration = Configuration.from_file(file_location)
    end

  end

end
