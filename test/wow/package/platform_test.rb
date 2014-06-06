require 'test/test_helper'
module Wow
  module Package
    class PlatformTest < ActiveSupport::TestCase

      def setup_platforms
        Wow::Config.send(:remove_const, :ASSET_FOLDER) if Wow::Config.const_defined?(:ASSET_FOLDER)
        Wow::Config.const_set(:ASSET_FOLDER, File.expand_path('../assets', __FILE__))
        Wow::Package::Platform.instance_variable_set(:@platforms, nil)
      end

      test 'should load platform right' do
        assert_not_nil Wow::Package::Platform.platforms
        assert_kind_of Tree, Wow::Package::Platform.platforms
      end

      test 'Test #based_on? should accept Wow::Package::Platform as argument' do
        parent = Wow::Package::Platform.new(:root)
        child = Wow::Package::Platform.new(:child1)
        assert Wow::Package::Platform.based_on?(parent, child)
      end

      test 'Test #based_on? should accept symbol as argument' do
        assert Wow::Package::Platform.based_on?(:root, :child1)
      end

      test 'Test #based_on? function' do
        setup_platforms
        should = [:child1, :root], [:subchild21, :root], [:subchild21, :child2], [:root, :root], [:child1, :child1], [:subchild11, :subchild11]
        should_not= [:root, :child1], [:root, :subchild11], [:child1, :child2], [:subchild11, :subchild22]
        should.each do |a|
          parent = Wow::Package::Platform.new(a[1])
          child = Wow::Package::Platform.new(a[0])
          puts Wow::Package::Platform.platforms
          assert Wow::Package::Platform.based_on?(parent, child), "#{a[1]} should be a parent of #{a[0]}"
        end
        should_not.each do |a|
          parent = Wow::Package::Platform.new(a[1])
          child = Wow::Package::Platform.new(a[0])
          assert_not Wow::Package::Platform.based_on?(parent, child), "#{a[1]} should be a parent of #{a[0]}"
        end
      end

      test 'Test the #is? method' do
        setup_platforms
        assert Wow::Package::Platform.new(:child1).is?(Wow::Package::Platform.new(:root))
      end

      test 'Test the #include? method' do
        setup_platforms
        assert_not Wow::Package::Platform.new(:root).is?(Wow::Package::Platform.new(:child1))
      end
    end
  end
end