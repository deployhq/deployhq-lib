# frozen_string_literal: true

require File.expand_path('lib/deploy/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'deployhq'
  s.version = Deploy::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.7'
  s.licenses = ['MIT']
  s.summary = 'API and CLI client for the DeployHQ'
  s.description = 'API and CLI client for the DeployHQ deployment platform. Provides the deployhq executable.'
  s.files = Dir.glob('{lib,bin}/**/*')
  s.require_paths = ['lib']
  s.bindir = 'bin'
  s.executables << 'deployhq'

  s.add_dependency('highline', '~> 2.1')
  s.add_dependency('json', '~> 2.6')
  s.add_dependency('websocket-eventmachine-client', '~> 1.2')

  s.authors = ['Adam Cooke']
  s.email = ['adam@k.io']
  s.homepage = 'https://github.com/krystal/deployhq-lib'
end
