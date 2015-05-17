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
      let (:hash) { {name: 'root', children:
          [{name: 'child1'},
           {name: 'child2',
            children: [
                {name: 'sub_child1'},
                {name: 'sub_child2'}
            ]}]} }

      subject { Tree.new(hash) }

      it { expect(subject.name).to eq('root') }
      it { expect(subject.children.size).to eq(2) }

    end
  end
end