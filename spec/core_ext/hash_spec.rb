require 'spec_helper'
require 'core_ext/hash'

RSpec.describe Hash do

  subject { {root: {child1: 'val1', child2: 'val2'}} }
  describe '#deep_find' do
    it { expect(subject.deep_find(:child1)).to eq('val1') }
    it { expect(subject.deep_find(:unknown)).to be nil }
  end

  describe '#deep_fetch' do
    it { expect(subject.deep_fetch(:child1)).to eq('val1') }
    it { expect(subject.deep_fetch(:unknown, :default)).to eq(:default) }
    it 'raise KeyError when key is not found and no default' do
      expect { subject.deep_fetch(:unknown) }.to raise_error(KeyError)
    end
  end
end