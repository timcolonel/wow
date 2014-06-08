require 'test/test_helper'

module Wow
  module Package
    class ConfigTest < ActiveSupport::TestCase
      test 'should list all files' do
        config = Wow::Package::Config.new
        config.files << 'assets/*.*'
        assert_not config.all_files.empty?
        assert config.all_files.include? 'assets/platforms.yml'
      end
    end
  end
end