require 'spec_helper'
require 'wow/package/version'
require 'wow/package/version_range'
Wow::Package::VersionRange.new('1.2.3')

def asset(path)
  File.join(File.dirname(__FILE__), 'assets', path)
end

RSpec.describe Wow::Package::VersionRange do
  describe '#initialize' do
    it 'set the lower bound to zero and parse the string when value is a string' do
      allow_any_instance_of(Wow::Package::VersionRange).to receive(:parse)
      subject = Wow::Package::VersionRange.new('~> 1.2')
      expect(subject.lower_bound).to eq(Wow::Package::Version.zero)
      expect(subject).to have_received(:parse).with('~> 1.2')
    end
    context 'when value is a Wow::Package::Version' do
      let(:version) { Wow::Package::Version.parse('1.2.3') }
      subject { Wow::Package::VersionRange.new(version) }
      it { expect(subject.lower_bound).to eq(version) }
      it { expect(subject.upper_bound).to eq(version) }
    end

    context 'when value is nil' do
      let(:lower_bound) { Wow::Package::Version.parse('1.2.3') }
      let(:upper_bound) { Wow::Package::Version.parse('2.0.0') }
      subject { Wow::Package::VersionRange.new(lower_bound: lower_bound, upper_bound: upper_bound) }
      it { expect(subject.lower_bound).to eq(lower_bound) }
      it { expect(subject.upper_bound).to eq(upper_bound) }
    end
  end

  describe '#merge' do
    context 'when argument as no upper bound' do
      let(:range) { Wow::Package::VersionRange.new('~> 1.2') }
      subject { range.merge(Wow::Package::VersionRange.new('>= 1.2.3')) }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('2.0.0')) }
    end

    context 'when base has no upper bound' do
      let(:range) { Wow::Package::VersionRange.new('>= 1.2.3') }
      subject { range.merge(Wow::Package::VersionRange.new('~> 1.2.0')) }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.3.0')) }
    end
  end

  describe '#parse' do
    let(:lower_bound) { Wow::Package::Version.parse('1.2.3') }

    it 'equal has the same lower and upper bound' do
      expect(Wow::Package::VersionRange.new('= 1.2.3').lower_bound).to eq(lower_bound)
      expect(Wow::Package::VersionRange.new('= 1.2.3').upper_bound).to eq(lower_bound)
    end

    it 'greater than has not upper bound' do
      expect(Wow::Package::VersionRange.new('>= 1.2.3').lower_bound).to eq(lower_bound)
      expect(Wow::Package::VersionRange.new('>= 1.2.3').upper_bound).to be nil
    end

    it 'pessimistic use the a custom upper bound' do
      expect(Wow::Package::VersionRange.new('~> 1.2.3').lower_bound).to eq(lower_bound)
      expect(Wow::Package::VersionRange.new('~> 1.2.3').upper_bound).to eq(lower_bound.pessimistic_upgrade)
    end

    it 'work with multiple conditions' do
      range = Wow::Package::VersionRange.new('~> 1.2,>=1.2.3')
      expect(range.lower_bound).to eq(lower_bound)
      expect(range.upper_bound).to eq(Wow::Package::Version.parse('2.0.0'))
    end

    context 'when using =' do
      subject { Wow::Package::VersionRange.new('= 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.include_lower_bound?).to be true }
    end

    context 'when giving just the version string' do
      subject { Wow::Package::VersionRange.new('1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.include_lower_bound?).to be true }
    end

    context 'when using >=' do
      subject { Wow::Package::VersionRange.new('>= 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to be nil }
      it { expect(subject.include_lower_bound?).to be true }
    end

    context 'when using >' do
      subject { Wow::Package::VersionRange.new('> 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to be nil }
      it { expect(subject.include_lower_bound?).to be false }
    end

    context 'when using <=' do
      subject { Wow::Package::VersionRange.new('<= 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.zero) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.include_upper_bound?).to be true }
    end

    context 'when using <' do
      subject { Wow::Package::VersionRange.new('< 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.zero) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.include_upper_bound?).to be false }
    end

    context 'when using ~>' do
      subject { Wow::Package::VersionRange.new('~> 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.3.0')) }
      it { expect(subject.include_upper_bound?).to be false }
      it { expect(subject).to eq(Wow::Package::VersionRange.new('>= 1.2.3, < 1.3.0')) }
    end

    context 'when having multiple conditions' do
      subject { Wow::Package::VersionRange.new('~> 1.2, >= 1.2.3') }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('2.0.0')) }
    end
  end

  describe 'match?' do
    context 'when range using equal' do
      subject { Wow::Package::VersionRange.new('= 1.2.3') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end

    context 'when range using more' do
      subject { Wow::Package::VersionRange.new('>= 1.2.3') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.20.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('2.0.1')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end

    context 'when range using pessimistic patch' do
      subject { Wow::Package::VersionRange.new('~> 1.2.3') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.20.3')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('2.0.1')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end

    context 'when range using pessimistic minor' do
      subject { Wow::Package::VersionRange.new('~> 1.2') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.20.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('2.0.1')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end
  end

  describe '#empty?' do
    it { expect(Wow::Package::VersionRange.new('~> 1.2.3,>= 2.0')).to be_empty }
    it { expect(Wow::Package::VersionRange.new('= 1.2,= 2.0')).to be_empty }
    it { expect(Wow::Package::VersionRange.new('>= 1.2,>= 2.0')).not_to be_empty }
  end

  describe '#any?' do
    it { expect(Wow::Package::VersionRange.new('>= 1.2,>= 2.0')).to be_any }
    it { expect(Wow::Package::VersionRange.new('= 1.2,= 2.0')).not_to be_any }

  end
end
