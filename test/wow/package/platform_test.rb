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

      test 'Based on function' do
        setup_platforms
        should = [:child1, :root], [:subchild21, :root], [:subchild21, :child2]
        should_not= [:root, :child1], [:root, :subchild11], [:child1, :child2], [:subchild11, :subchild22]
        should.each do |a|
          parent = Wow::Package::Platform.new(a[1])
          child = Wow::Package::Platform.new(a[0])
          assert Wow::Package::Platform.based_on?(parent, child), "#{a[1]} should be a parent of #{a[0]}"
        end
        should_not.each do |a|
          parent = Wow::Package::Platform.new(a[1])
          child = Wow::Package::Platform.new(a[0])
          assert_not Wow::Package::Platform.based_on?(parent, child), "#{a[1]} should be a parent of #{a[0]}"
        end
      end
    end
  end
end