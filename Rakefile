require 'rake/testtask'
require 'bundler/setup'
Bundler.setup

task :default => [:test]
Rake::TestTask.new do |t|
  t.libs = ['.']
  t.warning = false
  t.verbose = true
  t.test_files = FileList['test/**/*_test.rb']
end