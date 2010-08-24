Gem::Specification.new do |s|
  s.name = 'deployhq'
  s.version = "1.0.0"
  s.platform = Gem::Platform::RUBY
  s.summary = "API client for the DeployHQ deployment platform"
  
  s.files = Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
  s.has_rdoc = false

  s.add_dependency('json', '>= 1.4.6')

  s.author = "Adam Cooke"
  s.email = "adam@atechmedia.com"
  s.homepage = "http://www.deployhq.com"
end