require 'spec_helper'
require 'wow/package/target'


RSpec.describe Wow::Package::Target do
  change_asset_folder { File.expand_path('../assets', __FILE__) }
  before :each do
    Wow::Package::Target.instance_variable_set(:@platforms, nil)
  end

  describe '.platforms' do
    it 'load platforms' do
      expect(Wow::Package::Target.platforms).to be_a(Tree)
    end
  end

  describe '.based_on?' do
    it 'accept platform as argument' do
      parent = Wow::Package::Target.new(:root)
      child = Wow::Package::Target.new(:child1)
      expect(Wow::Package::Target.based_on?(parent, child)).to be true
    end

    it 'accept symbol as argument' do
      expect(Wow::Package::Target.based_on?(:root, :child1)).to be true
    end

    it 'is true when parent == child' do
      expect(Wow::Package::Target.based_on?(:child1, :child1)).to be true
    end

    it 'multiple cases' do
      should = [:child1, :root], [:subchild21, :root], [:subchild21, :child2], [:root, :root], [:child1, :child1], [:subchild11, :subchild11]
      should_not = [:root, :child1], [:root, :subchild11], [:child1, :child2], [:subchild11, :subchild22]
      should.each do |a|
        parent = Wow::Package::Target.new(a[1])
        child = Wow::Package::Target.new(a[0])
        expect(Wow::Package::Target.based_on?(parent, child)).to be(true), "#{a[1]} should be a parent of #{a[0]}"
      end
      should_not.each do |a|
        parent = Wow::Package::Target.new(a[1])
        child = Wow::Package::Target.new(a[0])
        expect(Wow::Package::Target.based_on?(parent, child)).to be(false), "#{a[1]} should not be a parent of #{a[0]}"
      end
    end

    it 'works with architecture' do
      parent = Wow::Package::Target.new(:root)
      child = Wow::Package::Target.new(:child1, :x86)
      expect(Wow::Package::Target.based_on?(parent, child)).to be true
    end

    it 'works with architecture' do
      parent = Wow::Package::Target.new(:root, :x64)
      child = Wow::Package::Target.new(:child1, :x86)
      expect(Wow::Package::Target.based_on?(parent, child)).to be false
    end

    it 'works with architecture' do
      parent = Wow::Package::Target.new(:root, :x64)
      child = Wow::Package::Target.new(:child1)
      expect(Wow::Package::Target.based_on?(parent, child)).to be false
    end
  end

  describe '#is?' do
    subject { Wow::Package::Target.new(:child1) }
    it 'is a child of the root' do
      expect(subject.is?(Wow::Package::Target.new(:root))).to be true
    end
  end

  describe '#include?' do
    subject { Wow::Package::Target.new(:child1) }
    it 'include a subchild' do
      expect(subject.include?(Wow::Package::Target.new(:subchild11))).to be true
    end
  end
end
