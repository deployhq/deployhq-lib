# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Deploy::Request do
  before do
    Deploy.configure do |config|
      config.account = 'https://test.deployhq.com'
      config.username = 'testuser'
      config.api_key = 'test-key'
    end
  end

  describe 'successful GET request' do
    it 'makes a GET request with proper authentication' do
      stub_request(:get, 'https://test.deployhq.com/test/path')
        .with(
          basic_auth: %w[testuser test-key],
          headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: '{"status":"ok"}', headers: {})

      request = described_class.new('test/path', :get)
      request.make

      expect(request.success?).to be true
      expect(request.output).to eq('{"status":"ok"}')
    end
  end

  describe 'successful POST request' do
    it 'makes a POST request with data' do
      stub_request(:post, 'https://test.deployhq.com/test/path')
        .with(
          basic_auth: %w[testuser test-key],
          headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
          body: '{"key":"value"}'
        )
        .to_return(status: 200, body: '{"created":true}', headers: {})

      request = described_class.new('test/path', :post)
      request.data = { 'key' => 'value' }
      request.make

      expect(request.success?).to be true
      expect(request.output).to eq('{"created":true}')
    end
  end

  describe 'error handling' do
    context 'when resource is not found' do
      it 'raises CommunicationError' do
        stub_request(:get, 'https://test.deployhq.com/missing')
          .to_return(status: 404, body: 'Not Found', headers: {})

        request = described_class.new('missing', :get)

        expect do
          request.make
        end.to raise_error(Deploy::Errors::CommunicationError, /Not Found/)
      end
    end

    context 'when access is forbidden' do
      it 'raises AccessDenied' do
        stub_request(:get, 'https://test.deployhq.com/forbidden')
          .to_return(status: 403, body: 'Forbidden', headers: {})

        request = described_class.new('forbidden', :get)

        expect do
          request.make
        end.to raise_error(Deploy::Errors::AccessDenied, /Access Denied/)
      end
    end

    context 'when unauthorized' do
      it 'raises AccessDenied' do
        stub_request(:get, 'https://test.deployhq.com/unauthorized')
          .to_return(status: 401, body: 'Unauthorized', headers: {})

        request = described_class.new('unauthorized', :get)

        expect { request.make }.to raise_error(Deploy::Errors::AccessDenied)
      end
    end

    context 'when service is unavailable' do
      it 'raises ServiceUnavailable' do
        stub_request(:get, 'https://test.deployhq.com/unavailable')
          .to_return(status: 503, body: 'Service Unavailable', headers: {})

        request = described_class.new('unavailable', :get)

        expect { request.make }.to raise_error(Deploy::Errors::ServiceUnavailable)
      end
    end

    context 'with client error' do
      it 'returns false and sets output' do
        stub_request(:get, 'https://test.deployhq.com/bad-request')
          .to_return(status: 400, body: 'Bad Request', headers: {})

        request = described_class.new('bad-request', :get)
        request.make

        expect(request.success?).to be false
        expect(request.output).to eq('Bad Request')
      end
    end
  end

  describe 'PUT request' do
    it 'makes a PUT request with data' do
      stub_request(:put, 'https://test.deployhq.com/test/123')
        .with(
          basic_auth: %w[testuser test-key],
          body: '{"status":"updated"}'
        )
        .to_return(status: 200, body: '{"updated":true}', headers: {})

      request = described_class.new('test/123', :put)
      request.data = { 'status' => 'updated' }
      request.make

      expect(request.success?).to be true
    end
  end

  describe 'DELETE request' do
    it 'makes a DELETE request' do
      stub_request(:delete, 'https://test.deployhq.com/test/123')
        .with(basic_auth: %w[testuser test-key])
        .to_return(status: 200, body: '', headers: {})

      request = described_class.new('test/123', :delete)
      request.make

      expect(request.success?).to be true
    end
  end
end
