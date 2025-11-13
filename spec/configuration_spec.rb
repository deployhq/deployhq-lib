# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Deploy::Configuration do
  describe '#websocket_hostname' do
    it 'has a default value' do
      config = described_class.new
      expect(config.websocket_hostname).to eq('wss://websocket.deployhq.com')
    end

    it 'allows setting a custom value' do
      config = described_class.new
      config.websocket_hostname = 'wss://custom.example.com'
      expect(config.websocket_hostname).to eq('wss://custom.example.com')
    end
  end

  describe 'attribute setters and getters' do
    it 'sets and retrieves all configuration attributes' do
      config = described_class.new
      config.account = 'https://test.deployhq.com'
      config.username = 'testuser'
      config.api_key = 'test-api-key'
      config.project = 'test-project'

      expect(config.account).to eq('https://test.deployhq.com')
      expect(config.username).to eq('testuser')
      expect(config.api_key).to eq('test-api-key')
      expect(config.project).to eq('test-project')
    end
  end

  describe '.from_file' do
    context 'with all fields present' do
      it 'loads configuration from JSON file' do
        config_data = {
          'account' => 'https://test.deployhq.com',
          'username' => 'testuser',
          'api_key' => 'test-key',
          'project' => 'test-project',
          'websocket_hostname' => 'wss://test.example.com'
        }

        Tempfile.create(['config', '.json']) do |f|
          f.write(JSON.generate(config_data))
          f.flush
          f.rewind

          config = described_class.from_file(f.path)

          expect(config.account).to eq('https://test.deployhq.com')
          expect(config.username).to eq('testuser')
          expect(config.api_key).to eq('test-key')
          expect(config.project).to eq('test-project')
          expect(config.websocket_hostname).to eq('wss://test.example.com')
        end
      end
    end

    context 'without websocket_hostname' do
      it 'uses the default websocket hostname' do
        config_data = {
          'account' => 'https://test.deployhq.com',
          'username' => 'testuser',
          'api_key' => 'test-key',
          'project' => 'test-project'
        }

        Tempfile.create(['config', '.json']) do |f|
          f.write(JSON.generate(config_data))
          f.flush
          f.rewind

          config = described_class.from_file(f.path)

          expect(config.account).to eq('https://test.deployhq.com')
          expect(config.websocket_hostname).to eq('wss://websocket.deployhq.com')
        end
      end
    end

    context 'with missing file' do
      it 'raises Errno::ENOENT' do
        expect do
          described_class.from_file('/nonexistent/file.json')
        end.to raise_error(Errno::ENOENT)
      end
    end

    context 'with invalid JSON' do
      it 'raises JSON::ParserError' do
        Tempfile.create(['config', '.json']) do |f|
          f.write('invalid json {')
          f.flush
          f.rewind

          expect do
            described_class.from_file(f.path)
          end.to raise_error(JSON::ParserError)
        end
      end
    end
  end
end
