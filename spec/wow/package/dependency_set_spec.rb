require 'spec_helper'

RSpec.describe Wow::Package::DependencySet do
  describe '#<<' do
    let(:dep) { Wow::Package::Dependency.new('a', '>= 1.2.3') }
    let(:new_dep) { Wow::Package::Dependency.new('a', '~> 1.2.0') }
    let(:diff_dep) { Wow::Package::Dependency.new('b', '>= 1.2.0') }
    context 'when name is not there' do
      subject { Wow::Package::DependencySet.new }
      before do
        subject << dep
      end
      it { expect(subject.size).to be 1 }
      it { expect(subject).to include(dep) }
    end

    context 'when dependency is already inside' do
      subject { Wow::Package::DependencySet.new([dep]) }
      before do
        subject << dep
      end
      it { expect(subject.size).to be 1 }
      it { expect(subject).to include(dep) }
    end

    context 'when dependency can be merged' do
      subject { Wow::Package::DependencySet.new([dep]) }
      before do
        subject << new_dep
        puts subject
      end
      it { expect(subject.size).to be 1 }
      it { expect(subject).to include(Wow::Package::Dependency.new('a', '~> 1.2.3')) }
    end

    context 'when inserting different dependency' do
      subject { Wow::Package::DependencySet.new([dep]) }
      before do
        subject << diff_dep
      end
      it { expect(subject.size).to be 2 }
      it { expect(subject).to include(dep) }
      it { expect(subject).to include(diff_dep) }
    end
  end
end
