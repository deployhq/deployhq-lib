Gem::Specification.new do |s|
  s.name = 'deployhq'
  s.version = "1.0.0"
  s.platform = Gem::Platform::RUBY
  s.summary = "API client for the DeployHQ deployment platform"
  
  s.files = ['bin/deployhq'] + Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
  s.bindir = "bin"
  s.executables << "deploy"
  s.has_rdoc = false

  s.add_dependency('json', '>= 1.8.0')
  s.add_dependency('highline', '>= 1.6.16')

  s.author = "Adam Cooke"
  s.email = "adam@atechmedia.com"
  s.homepage = "http://www.deployhq.com"
end