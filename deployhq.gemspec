# frozen_string_literal: true

require File.expand_path('lib/deploy/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'deployhq'
  s.version = Deploy::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.7'
  s.licenses = ['MIT']
  s.summary = 'API and CLI client for the DeployHQ (CLI deprecated)'
  s.description = 'API and CLI client for the DeployHQ deployment platform. ' \
                  'NOTE: The CLI is deprecated. ' \
                  'Please use https://github.com/deployhq/deployhq-cli instead.'
  s.files = Dir.glob('{lib,bin}/**/*')
  s.require_paths = ['lib']
  s.bindir = 'bin'
  s.executables << 'deployhq'

  s.add_dependency('highline', '~> 2.1')
  s.add_dependency('json', '~> 2.6')
  s.add_dependency('websocket-eventmachine-client', '~> 1.2')

  s.authors = ['DeployHQ Team']
  s.email = ['support@deployhq.com']
  s.homepage = 'https://github.com/deployhq/deployhq-lib'
  s.post_install_message = <<~MSG
    WARNING: The DeployHQ CLI bundled in this gem is deprecated.
    Please migrate to the new CLI: https://github.com/deployhq/deployhq-cli
  MSG
end
