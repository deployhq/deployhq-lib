# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'webmock/minitest'
require 'deploy'

# Disable external HTTP requests during tests
WebMock.disable_net_connect!
