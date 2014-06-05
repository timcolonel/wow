require 'test/test_helper'
module Wow
  module Package
    class PlatformTest < ActiveSupport::TestCase
      test 'should load platform right' do
        assert_not_nil Wow::Package::Platform.platforms
        assert_kind_of Hash, Wow::Package::Platform.platforms
      end
    end
  end
end