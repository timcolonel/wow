$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'wow/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'wow'
  s.version = Wow::VERSION
  s.authors = ['Timothee Guerin']
  s.email = %w(timothee.guerin@outlook.com)
  s.homepage = 'http://github.com/timcolonel/wow'
  s.summary = 'Wow library and command line'
  s.description = ''

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rake'
  s.add_dependency 'activesupport'
  s.add_dependency 'activemodel'
  s.add_dependency 'docopt'
  s.add_dependency 'toml-rb', '>= 0.3.5'
  s.add_dependency 'require_all'
  s.add_dependency 'rest-client'
  s.add_dependency 'clin', '>= 0.4.0'
  s.add_dependency 'os'

  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'rspec'
end
