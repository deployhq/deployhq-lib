# frozen_string_literal: true

module Deploy
  class Configuration

    attr_accessor :account
    attr_accessor :username
    attr_accessor :api_key
    attr_accessor :project
    attr_writer :websocket_hostname

    def websocket_hostname
      @websocket_hostname || 'wss://websocket.deployhq.com'
    end

    def self.from_file(path)
      file_contents = File.read(path)
      parsed_contents = JSON.parse(file_contents)

      new.tap do |config|
        config.account = parsed_contents['account']
        config.username = parsed_contents['username']
        config.api_key = parsed_contents['api_key']
        config.project = parsed_contents['project']
        config.websocket_hostname = parsed_contents['websocket_hostname']
      end
    end

  end
end
