require 'test/test_helper'

module Wow
  module Package
    class ConfigTest < ActiveSupport::TestCase
      test 'should list all files' do
        config = Wow::Package::Config.new
        config.file_patterns << 'assets/*.*'
        assert_not config.files.empty?
        assert config.files.include? 'assets/platforms.yml'
      end

      test 'validate should fail without name' do
        config = Wow::Package::Config.new
        config.version = '1.0.0'
        assert_not config.valid?
      end

      test 'validate should fail with bad name' do
        config = Wow::Package::Config.new
        config.name = 'Bad name with space'
        config.version = '1.0.0'
        assert_not config.valid?
      end

      test 'validate should fail without version' do
        config = Wow::Package::Config.new
        config.name = 'super_name'
        assert_not config.valid?
      end

      test 'validate should fail with absolute path' do
        config = Wow::Package::Config.new
        config.name = 'super_name'
        config.version = '1.0.0'
        config.file_patterns << '/absolute/path'
        assert_not config.valid?
      end

      test 'validate should succeed' do
        config = Wow::Package::Config.new
        config.name = 'super_name'
        config.version = '1.0.0'
        config.file_patterns << 'relative/path'
        assert config.valid?, "Should be valid!, #{config.errors.full_messages}"
      end

      test 'should create config from string' do
        config = Wow::Package::Config.new
        filename = 'dumfile.txt'
        config.init_from_rb("file '#{filename}'")
        puts config.file_patterns
        assert config.file_patterns.include?(filename)
      end
    end
  end
end