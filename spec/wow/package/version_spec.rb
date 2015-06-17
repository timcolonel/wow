require 'spec_helper'
require 'wow/package/version'

RSpec.describe Wow::Package::Version, type: :model do
  describe '#to_s' do
    subject { Wow::Package::Version.new(major: 1, minor: 2, patch: 3) }

    it { expect(subject.to_s).to eq('1.2.3') }
    context 'when stage is specified' do
      before do
        subject.stage = :beta
      end
      it { expect(subject.to_s).to eq('1.2.3.b') }
      it { expect(subject.to_s(short: false)).to eq('1.2.3.beta') }
    end

    context 'when identifier is specified' do
      before do
        subject.identifier = 764
      end
      it { expect(subject.to_s).to eq('1.2.3.764') }
      it { expect(subject.to_s(hide_release: false)).to eq('1.2.3.r.764') }
      it { expect(subject.to_s(short: false, hide_release: false)).to eq('1.2.3.release.764') }

    end

    context 'when stage and identifier are specified' do
      before do
        subject.stage = :alpha
        subject.identifier = 717
      end
      it { expect(subject.to_s).to eq('1.2.3.a.717') }
      it { expect(subject.to_s(short: false)).to eq('1.2.3.alpha.717') }
    end
  end

  describe '.parse' do
    context 'when version string is a wrong format' do
      it { expect { Wow::Package::Version.parse('1') }.to raise_error(ArgumentError) }
      it { expect { Wow::Package::Version.parse('1.2') }.to raise_error(ArgumentError) }

      it { expect { Wow::Package::Version.parse('1.2', true) }.not_to raise_error }

      it { expect { Wow::Package::Version.parse('1.2.3-') }.to raise_error(ArgumentError) }
      it { expect { Wow::Package::Version.parse('1.2.3+r') }.to raise_error(ArgumentError) }
      it { expect { Wow::Package::Version.parse('1.2.3b') }.to raise_error(ArgumentError) }
    end

    context 'when version string is in simple format' do
      subject { Wow::Package::Version.parse('1.2.3') }

      it { expect(subject.major).to eq(1) }
      it { expect(subject.minor).to eq(2) }
      it { expect(subject.patch).to eq(3) }
      it { expect(subject.stage).to eq(:release) }
    end

    context 'when version string include stage' do
      context 'when stage is full' do
        subject { Wow::Package::Version.parse('1.2.3-beta') }

        it { expect(subject.major).to eq(1) }
        it { expect(subject.minor).to eq(2) }
        it { expect(subject.patch).to eq(3) }
        it { expect(subject.stage).to eq(:beta) }
      end

      context 'when stage is given with initial' do
        subject { Wow::Package::Version.parse('1.2.3-b') }

        it { expect(subject.major).to eq(1) }
        it { expect(subject.minor).to eq(2) }
        it { expect(subject.patch).to eq(3) }
        it { expect(subject.stage).to eq(:beta) }
      end

      context 'when stage is using dot for separation' do
        subject { Wow::Package::Version.parse('1.2.3.b') }

        it { expect(subject.major).to eq(1) }
        it { expect(subject.minor).to eq(2) }
        it { expect(subject.patch).to eq(3) }
        it { expect(subject.stage).to eq(:beta) }
      end
    end

    context 'when version string include identifier' do
      subject { Wow::Package::Version.parse('1.2.3.980') }

      it { expect(subject.major).to eq(1) }
      it { expect(subject.minor).to eq(2) }
      it { expect(subject.patch).to eq(3) }
      it { expect(subject.stage).to eq(:release) }
      it { expect(subject.identifier).to eq(980) }
    end

    context 'when version string include stage and identifier' do
      subject { Wow::Package::Version.parse('1.2.3-rc.980') }

      it { expect(subject.major).to eq(1) }
      it { expect(subject.minor).to eq(2) }
      it { expect(subject.patch).to eq(3) }
      it { expect(subject.stage).to eq(:release_candidate) }
      it { expect(subject.identifier).to eq(980) }
    end
  end

  describe '#unique' do
    it { expect(Wow::Package::Version.parse('1.2.3.a').unique).to be < Wow::Package::Version.parse('1.2.3.rc').unique }
    it { expect(Wow::Package::Version.parse('1.2.3.rc').unique).to be < Wow::Package::Version.parse('1.2.3').unique }
    it { expect(Wow::Package::Version.parse('1.2.3').unique).to be < Wow::Package::Version.parse('1.2.4').unique }
    it { expect(Wow::Package::Version.parse('1.2.3').unique).to be < Wow::Package::Version.parse('1.20.3').unique }
    it { expect(Wow::Package::Version.parse('1.20.3').unique).to be < Wow::Package::Version.parse('2.0.0').unique }
    it { expect(Wow::Package::Version.parse('1.20.3').unique).to be < Wow::Package::Version.parse('2.0.0').unique }

    it { expect(Wow::Package::Version.parse('1.2.3.999').unique).to be < Wow::Package::Version.parse('1.2.3.1000').unique }
    it { expect(Wow::Package::Version.parse('999.999.999.99998').unique).to be < Wow::Package::Version.parse('999.999.999.99999').unique }
    it { expect { Wow::Package::Version.parse('1000.0.0').unique }.to raise_error(ArgumentError) }
    it { expect { Wow::Package::Version.parse('1.0.0.100000').unique }.to raise_error(ArgumentError) }
  end

  describe '#<=>' do
    it { expect(Wow::Package::Version.parse('1.2.3') <=> Wow::Package::Version.parse('1.2.4')).to be -1 }
    it { expect(Wow::Package::Version.parse('2.0.0') <=> Wow::Package::Version.parse('1.2.4')).to be 1 }
    it { expect(Wow::Package::Version.parse('2.0.0') <=> Wow::Package::Version.parse('2.0.0')).to be 0 }
    it { expect(Wow::Package::Version.parse('2.0.0') >= Wow::Package::Version.parse('2.0.0')).to be true }
    it { expect(Wow::Package::Version.parse('2.0.0') <= Wow::Package::Version.parse('2.0.0')).to be true }
    it { expect(Wow::Package::Version.parse('2.0.0') < Wow::Package::Version.parse('2.0.0')).to be false }
    it { expect(Wow::Package::Version.parse('2.0.0') < Wow::Package::Version.parse('2.0.0')).to be false }
    it { expect(Wow::Package::Version.parse('2.0.0') > Wow::Package::Version.parse('2.0.0')).to be false }

    it { expect(Wow::Package::Version.parse('1.2.4') > Wow::Package::Version.parse('1.2.3')).to be true }
    it { expect(Wow::Package::Version.parse('1.2.4') < Wow::Package::Version.parse('1.2.3')).to be false }
  end

  describe '#get_upper_bound' do
    it { expect(Wow::Package::Version.parse('1.2', true).pessimistic_upgrade.to_s).to eq('2.0.0') }
    it { expect(Wow::Package::Version.parse('1.2.3').pessimistic_upgrade.to_s).to eq('1.3.0') }
  end
end
