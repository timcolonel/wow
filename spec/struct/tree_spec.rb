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
  end
end