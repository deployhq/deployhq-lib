# frozen_string_literal: true

require 'test_helper'

class RequestTest < Minitest::Test

  def setup
    Deploy.configure do |config|
      config.account = 'https://test.deployhq.com'
      config.username = 'testuser'
      config.api_key = 'test-key'
    end
  end

  def test_successful_get_request
    stub_request(:get, 'https://test.deployhq.com/test/path')
      .with(
        basic_auth: %w[testuser test-key],
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
      )
      .to_return(status: 200, body: '{"status":"ok"}', headers: {})

    request = Deploy::Request.new('test/path', :get)
    request.make

    assert request.success?
    assert_equal '{"status":"ok"}', request.output
  end

  def test_successful_post_request
    stub_request(:post, 'https://test.deployhq.com/test/path')
      .with(
        basic_auth: %w[testuser test-key],
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        body: '{"key":"value"}'
      )
      .to_return(status: 200, body: '{"created":true}', headers: {})

    request = Deploy::Request.new('test/path', :post)
    request.data = { 'key' => 'value' }
    request.make

    assert request.success?
    assert_equal '{"created":true}', request.output
  end

  def test_not_found_error
    stub_request(:get, 'https://test.deployhq.com/missing')
      .to_return(status: 404, body: 'Not Found', headers: {})

    request = Deploy::Request.new('missing', :get)

    error = assert_raises(Deploy::Errors::CommunicationError) do
      request.make
    end

    assert_match(/Not Found/, error.message)
  end

  def test_access_denied_error
    stub_request(:get, 'https://test.deployhq.com/forbidden')
      .to_return(status: 403, body: 'Forbidden', headers: {})

    request = Deploy::Request.new('forbidden', :get)

    error = assert_raises(Deploy::Errors::AccessDenied) do
      request.make
    end

    assert_match(/Access Denied/, error.message)
  end

  def test_unauthorized_error
    stub_request(:get, 'https://test.deployhq.com/unauthorized')
      .to_return(status: 401, body: 'Unauthorized', headers: {})

    request = Deploy::Request.new('unauthorized', :get)

    assert_raises(Deploy::Errors::AccessDenied) do
      request.make
    end
  end

  def test_service_unavailable_error
    stub_request(:get, 'https://test.deployhq.com/unavailable')
      .to_return(status: 503, body: 'Service Unavailable', headers: {})

    request = Deploy::Request.new('unavailable', :get)

    assert_raises(Deploy::Errors::ServiceUnavailable) do
      request.make
    end
  end

  def test_client_error_returns_false
    stub_request(:get, 'https://test.deployhq.com/bad-request')
      .to_return(status: 400, body: 'Bad Request', headers: {})

    request = Deploy::Request.new('bad-request', :get)
    request.make

    refute request.success?
    assert_equal 'Bad Request', request.output
  end

  def test_put_request
    stub_request(:put, 'https://test.deployhq.com/test/123')
      .with(
        basic_auth: %w[testuser test-key],
        body: '{"status":"updated"}'
      )
      .to_return(status: 200, body: '{"updated":true}', headers: {})

    request = Deploy::Request.new('test/123', :put)
    request.data = { 'status' => 'updated' }
    request.make

    assert request.success?
  end

  def test_delete_request
    stub_request(:delete, 'https://test.deployhq.com/test/123')
      .with(basic_auth: %w[testuser test-key])
      .to_return(status: 200, body: '', headers: {})

    request = Deploy::Request.new('test/123', :delete)
    request.make

    assert request.success?
  end

end
