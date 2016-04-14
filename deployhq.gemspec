require 'deploy/version'

Gem::Specification.new do |s|
  s.name = 'deployhq'
  s.version = Deploy::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "API and CLI client for the DeployHQ deployment platform"

  s.files = ['bin/deployhq'] + Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
  s.bindir = "bin"
  s.executables << "deployhq"
  s.has_rdoc = false

  s.add_dependency('json', '~> 1.8.0')
  s.add_dependency('highline', '~> 1.7.0')

  s.author = "Dan Wentworth"
  s.email = "dan@atech.io"
  s.homepage = "https://www.deployhq.com"
end
