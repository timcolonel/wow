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

      test 'validate should fail' do 
        assert_raise WowError do 
          Wow::Package::Config.new.validate!
        end
      end
      test 'validate should fail without version' do 
        assert_raise WowError do 
          config = Wow::Package::Config.new
          config.name = 'Super name'
          config.validate!
        end
      end

       test 'validate should fail with absolute path' do 
        assert_raise WowError do 
          config = Wow::Package::Config.new
          config.name = 'Super name'
          config.version = '1.0.0'
          config.file_patterns << 'D:/absolute/path'
          config.validate!
        end
      end
    end
  end
end