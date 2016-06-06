require_relative 'lib/spy/version'

Gem::Specification.new do |s|
  s.name        = 'spy_rb'
  s.version     = Spy::VERSION
  s.licenses    = ['MIT']
  s.summary     = "SinonJS-style Test Spies for Ruby"
  s.description = "Spy brings everything that's great about Sinon.JS to Ruby. Mocking frameworks work by stubbing out functionality. Spy works by listening in on functionality and allowing it to run in the background. Spy is designed to be lightweight and work alongside Mocking frameworks instead of trying to replace them entirely."
  s.authors     = ["Josh Bodah"]
  s.email       = 'jb3689@yahoo.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/jbodah/spy_rb'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-tagz'
end
