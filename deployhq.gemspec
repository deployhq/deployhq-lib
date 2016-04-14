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

  s.files = ['bin/deployhq'] + Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
  s.bindir = "bin"
  s.executables << "deployhq"
  s.has_rdoc = false

  s.add_dependency('json', '~> 1.8')
  s.add_dependency('highline', '~> 1.7')

  s.author = "Dan Wentworth"
  s.email = "dan@atech.io"
  s.homepage = "https://www.deployhq.com"
end
