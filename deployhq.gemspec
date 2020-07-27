require File.expand_path('../lib/deploy/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'deployhq'
  s.version = Deploy::VERSION
  s.platform = Gem::Platform::RUBY
  s.licenses = ['MIT']
  s.summary = "API and CLI client for the DeployHQ"
  s.description = <<-EOF
    API and CLI client for the DeployHQ deployment platform. Provides the
    deployhq executable.
  EOF

  s.files = Dir.glob("{lib,bin}/**/*")
  s.require_paths = ["lib"]
  s.bindir = "bin"
  s.executables << "deployhq"

  s.add_dependency('json', '>= 1.8', '< 3.0')
  s.add_dependency('highline', '~> 2.0')
  s.add_dependency('websocket-eventmachine-client', '~> 1.2')

  s.author = "Dan Wentworth"
  s.email = "dan@atech.io"
  s.homepage = "https://www.deployhq.com"
end
