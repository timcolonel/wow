require 'spec_helper'
require 'wow/package/version'
require 'wow/package/version_range'

def asset(path)
  File.join(File.dirname(__FILE__), 'assets', path)
end

RSpec.describe Wow::Package::VersionRange do
  describe '#merge' do
    context 'when argument as no upper bound' do
      let(:range) { Wow::Package::VersionRange.parse('~> 1.2') }
      subject { range.merge(Wow::Package::VersionRange.parse('>= 1.2.3')) }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('2.0.0')) }
    end

    context 'when base has no upper bound' do
      let(:range) { Wow::Package::VersionRange.parse('>= 1.2.3') }
      subject { range.merge(Wow::Package::VersionRange.parse('~> 1.2.0')) }
      it { expect(subject.lower_bound).to eq(Wow::Package::Version.parse('1.2.3')) }
      it { expect(subject.upper_bound).to eq(Wow::Package::Version.parse('1.3.0')) }
    end
  end

  describe '.parse' do
    let(:lower_bound) { Wow::Package::Version.parse('1.2.3') }

    it 'equal has the same lower and upper bound' do
      expect(Wow::Package::VersionRange.parse('= 1.2.3').lower_bound).to eq(lower_bound)
      expect(Wow::Package::VersionRange.parse('= 1.2.3').upper_bound).to eq(lower_bound)
    end

    it 'greater than has not upper bound' do
      expect(Wow::Package::VersionRange.parse('>= 1.2.3').lower_bound).to eq(lower_bound)
      expect(Wow::Package::VersionRange.parse('>= 1.2.3').upper_bound).to be nil
    end

    it 'pessimistic use the a custom upper bound' do
      expect(Wow::Package::VersionRange.parse('~> 1.2.3').lower_bound).to eq(lower_bound)
      expect(Wow::Package::VersionRange.parse('~> 1.2.3').upper_bound).to eq(lower_bound.get_upper_bound)
    end

    it 'work with multiple conditions' do
      range = Wow::Package::VersionRange.parse('~> 1.2,>=1.2.3')
      expect(range.lower_bound).to eq(lower_bound)
      expect(range.upper_bound).to eq(Wow::Package::Version.parse('2.0.0'))
    end
  end

  describe 'match?' do
    context 'when range using equal' do
      subject { Wow::Package::VersionRange.parse('= 1.2.3') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end

    context 'when range using more' do
      subject { Wow::Package::VersionRange.parse('>= 1.2.3') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.20.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('2.0.1')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end

    context 'when range using pessimistic patch' do
      subject { Wow::Package::VersionRange.parse('~> 1.2.3') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.20.3')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('2.0.1')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end

    context 'when range using pessimistic minor' do
      subject { Wow::Package::VersionRange.parse('~> 1.2') }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.2.4')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('1.20.3')).to be true }
      it { expect(subject.match? Wow::Package::Version.parse('2.0.1')).to be false }
      it { expect(subject.match? Wow::Package::Version.parse('1.0.0')).to be false }
    end
  end

  describe '#empty?' do
    it { expect(Wow::Package::VersionRange.parse('~> 1.2.3,>= 2.0')).to be_empty }
    it { expect(Wow::Package::VersionRange.parse('= 1.2,= 2.0')).to be_empty }
    it { expect(Wow::Package::VersionRange.parse('>= 1.2,>= 2.0')).not_to be_empty }
  end

  describe '#any?' do
    it { expect(Wow::Package::VersionRange.parse('>= 1.2,>= 2.0')).to be_any }
    it { expect(Wow::Package::VersionRange.parse('= 1.2,= 2.0')).not_to be_any }

  end
end
