require 'test/test_helper'
module Wow
  module Package
    class PlatformTest < ActiveSupport::TestCase

      def setup_platforms
        platforms = {
            :root => {
                :child1 => {:subchild11 => '', :subchild12 => ''},
                :child2 => {:subchild21 => '', :subchild22 => ''}
            }
        }
        Wow::Package::Platform.instance_variable_set(:@platforms, platforms)
      end

      test 'should load platform right' do
        assert_not_nil Wow::Package::Platform.platforms
        assert_kind_of Hash, Wow::Package::Platform.platforms
      end

      test '#is? function' do
        Wow::Package::Platform.platforms
        setup_platforms
        assert Wow::Package::Platform.new(:child1).is?(Wow::Package::Platform.new(:root))
        assert Wow::Package::Platform.new(:subchild21).is? (Wow::Package::Platform.new(:root))
        assert Wow::Package::Platform.new(:subchild21).is?(Wow::Package::Platform.new(:child2))
        assert !Wow::Package::Platform.new(:root).is?(Wow::Package::Platform.new(:child1))
        assert !Wow::Package::Platform.new(:root).is?(Wow::Package::Platform.new(:subchild11))
        assert !Wow::Package::Platform.new(:child1).is?(Wow::Package::Platform.new(:child2))
        assert !Wow::Package::Platform.new(:subchild11).is?(Wow::Package::Platform.new(:subchild22))
      end
    end
  end
end