require 'spec_helper'
require 'struct/tree'

RSpec.describe Tree do
  describe '#initialize' do
    context 'when argument is a string' do
      let (:key) { Faker::Lorem.word }
      subject { Tree.new(key) }

      it { expect(subject.name).to eq(key) }
      it { expect(subject.children).to be_empty }
    end

    context 'when argument is a hash with name and children format' do
      let (:child1) { {name: 'child1'} }
      let (:child2) { {name: 'child2',
                       children: [
                           {name: 'sub_child1'},
                           {name: 'sub_child2'}]} }

      let (:hash) { {name: 'root', children: [child1, child2]} }

      subject { Tree.new(hash) }

      it { expect(subject.name).to eq('root') }
      it { expect(subject.children.size).to eq(2) }
      it { expect(subject.children[0].name).to eq(child1[:name]) }
      it { expect(subject.children[1].name).to eq(child2[:name]) }
      it { expect(subject.children[1].children.size).to eq(2) }
    end

    context 'when argument is a hash/array combination' do
      let (:child1) { 'child1' }
      let (:child2) { {child2: %w(sub_child1 sub_child2)} }

      let (:hash) { {root: [child1, child2]} }

      subject { Tree.new(hash) }

      it { expect(subject.name).to eq(:root) }
      it { expect(subject.children.size).to eq(2) }
      it { expect(subject.children[0].name).to eq(child1) }
      it { expect(subject.children[1].name).to eq(child2.first[0]) }
      it { expect(subject.children[1].children.size).to eq(2) }
    end
  end

  describe '#<<' do
    subject { Tree.new(:root) }
    let (:child) { Tree.new(:child) }
    before do
      subject << child
    end

    it { expect(subject.children.size).to eq(1) }
    it { expect(subject.children.first).to eq(child) }
  end

  describe '#deep_symbolize!' do
    subject { Tree.new('root') }
    before do
      subject.deep_symbolize!
    end

    it { expect(subject.name).to be_a Symbol }
    it { expect(subject.name).to eq(:root) }

    context 'when tree has children' do
      before do
        subject << Tree.new('child')
        subject.deep_symbolize!
      end
      it { expect(subject.children.first.name).to be_a Symbol }
      it { expect(subject.children.first.name).to eq(:child) }
    end
  end

  describe '#deep_symbolize' do
    subject { Tree.new('root') }
    before do
      subject << Tree.new('child')
      @clone = subject.deep_symbolize
    end


    it { expect(subject.name).to be_a String }
    it { expect(@clone.name).to be_a Symbol }
    it { expect(@clone.name).to eq(:root) }

    it { expect(subject.children.first.name).to be_a String }
    it { expect(@clone.children.first.name).to be_a Symbol }
    it { expect(@clone.children.first.name).to eq(:child) }
  end

  describe '#to_hash' do
    subject { Tree.new(:root).add_child(:child1).add_child(:child2) }

    it { expect(subject.to_hash).to be_a Hash }
    it { expect(subject.to_hash).to have_key :name }
    it { expect(subject.to_hash).to have_key :children }
    it { expect(subject.to_hash[:name]).to eq(:root) }
    it { expect(subject.to_hash[:children].size).to be 2 }

  end

  describe '#to_s' do
    subject { Tree.new(:root).add_child(:child1).add_child(:child2) }

    it { expect(subject.to_s).to be_a String }
  end
end