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
    end
  end
end