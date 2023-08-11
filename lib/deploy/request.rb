require 'faraday'
require 'json'

module Deploy
  class Request

    attr_reader :path, :method
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
      uri = URI.parse(Deploy.configuration.account)
      connection_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"

      connection = Faraday.new(url: connection_url, request: { timeout: 3 }) do |client|
        client.request :authorization, :basic, Deploy.configuration.username, Deploy.configuration.api_key
        client.headers['Accept'] = 'application/json'
        client.headers['Content-Type'] = 'application/json'
      end

      data = self.data.to_json if self.data.is_a?(Hash) && self.data.respond_to?(:to_json)

      response = connection.send(@method) do |req|
        req.url @path
        req.body = data
      end

      @output = response.body
      @success = case response.status
                 when 200..299
                   true
                 when 503
                   raise Deploy::Errors::ServiceUnavailable
                 when 401, 403
                   raise Deploy::Errors::AccessDenied, "Access Denied for '#{Deploy.configuration.username}'"
                 when 404
                   raise Deploy::Errors::CommunicationError, "Not Found at #{uri.to_s}"
                 when 400..499
                   false
                 else
                   raise Deploy::Errors::CommunicationError, response.body
                 end

      self
    rescue Faraday::TimeoutError
      raise Deploy::Errors::TimeoutError, "Your request timed out, please try again in a few seconds"
    end

  end
end
