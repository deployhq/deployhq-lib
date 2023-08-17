# frozen_string_literal: true

require 'json'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
module Deploy
  class Request

    attr_reader :path
    attr_reader :method
    attr_accessor :data

    def initialize(path, method = :get)
      @path = path
      @method = method
    end

    def success?
      @success || false
    end

    def output
      @output || nil
    end

    ## Make a request to the Deploy API using net/http. Data passed can be a hash or a string
    ## Hashes will be converted to JSON before being sent to the remote service.
    def make
      uri = URI.parse([Deploy.configuration.account, @path].join('/'))
      http_request = http_class.new(uri.request_uri)
      http_request.basic_auth(Deploy.configuration.username, Deploy.configuration.api_key)
      http_request['Accept'] = 'application/json'
      http_request['Content-Type'] = 'application/json'

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      data = self.data.to_json if self.data.is_a?(Hash) && self.data.respond_to?(:to_json)
      http_result = http.request(http_request, data)
      @output = http_result.body
      case http_result
      when Net::HTTPSuccess
        @success = true
      when Net::HTTPServiceUnavailable
        @success = raise Deploy::Errors::ServiceUnavailable
      when Net::HTTPForbidden, Net::HTTPUnauthorized
        @success = raise Deploy::Errors::AccessDenied, "Access Denied for '#{Deploy.configuration.username}'"
      when Net::HTTPNotFound
        @success = raise Deploy::Errors::CommunicationError, "Not Found at #{uri}"
      when Net::HTTPClientError
        @success = false
      else
        @success = raise Deploy::Errors::CommunicationError, http_result.body
      end
      self
    end

    private

    def http_class
      case @method
      when :post    then Net::HTTP::Post
      when :put     then Net::HTTP::Put
      when :delete  then Net::HTTP::Delete
      else
        Net::HTTP::Get
      end
    end

  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength
