module Deploy
  class Configuration
    attr_accessor :account, :username, :api_key, :project

    def self.from_file(path)
      file_contents = File.read(path)
      parsed_contents = JSON.parse(file_contents)

      self.new.tap do |config|
        config.account = parsed_contents['account']
        config.username = parsed_contents['username']
        config.api_key = parsed_contents['api_key']
        config.project = parsed_contents['project']
      end
    end
  end
end
