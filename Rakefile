require 'rake/testtask'
require 'bundler/setup'
Bundler.setup

Rake::TestTask.new do |t|
  t.libs = ['.']
  t.warning = false
  t.verbose = true
  t.test_files = FileList['test/**/*_test.rb']
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  # no rspec available
end
