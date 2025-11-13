# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

class ConfigurationTest < Minitest::Test

  def test_default_websocket_hostname
    config = Deploy::Configuration.new
    assert_equal 'wss://websocket.deployhq.com', config.websocket_hostname
  end

  def test_custom_websocket_hostname
    config = Deploy::Configuration.new
    config.websocket_hostname = 'wss://custom.example.com'
    assert_equal 'wss://custom.example.com', config.websocket_hostname
  end

  def test_setting_attributes
    config = Deploy::Configuration.new
    config.account = 'https://test.deployhq.com'
    config.username = 'testuser'
    config.api_key = 'test-api-key'
    config.project = 'test-project'

    assert_equal 'https://test.deployhq.com', config.account
    assert_equal 'testuser', config.username
    assert_equal 'test-api-key', config.api_key
    assert_equal 'test-project', config.project
  end

  def test_from_file_with_all_fields
    config_data = {
      'account' => 'https://test.deployhq.com',
      'username' => 'testuser',
      'api_key' => 'test-key',
      'project' => 'test-project',
      'websocket_hostname' => 'wss://test.example.com'
    }

    Tempfile.create(['config', '.json']) do |f|
      f.write(JSON.generate(config_data))
      f.rewind

      config = Deploy::Configuration.from_file(f.path)

      assert_equal 'https://test.deployhq.com', config.account
      assert_equal 'testuser', config.username
      assert_equal 'test-key', config.api_key
      assert_equal 'test-project', config.project
      assert_equal 'wss://test.example.com', config.websocket_hostname
    end
  end

  def test_from_file_without_websocket_hostname
    config_data = {
      'account' => 'https://test.deployhq.com',
      'username' => 'testuser',
      'api_key' => 'test-key',
      'project' => 'test-project'
    }

    Tempfile.create(['config', '.json']) do |f|
      f.write(JSON.generate(config_data))
      f.rewind

      config = Deploy::Configuration.from_file(f.path)

      assert_equal 'https://test.deployhq.com', config.account
      assert_equal 'wss://websocket.deployhq.com', config.websocket_hostname
    end
  end

  def test_from_file_raises_on_missing_file
    assert_raises(Errno::ENOENT) do
      Deploy::Configuration.from_file('/nonexistent/file.json')
    end
  end

  def test_from_file_raises_on_invalid_json
    Tempfile.create(['config', '.json']) do |f|
      f.write('invalid json {')
      f.rewind

      assert_raises(JSON::ParserError) do
        Deploy::Configuration.from_file(f.path)
      end
    end
  end

end
