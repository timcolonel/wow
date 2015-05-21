require 'spec_helper'
require 'wow/source/local'

RSpec.describe Wow::Source::Local do
  subject { Wow::Source::Local.new(@folder.to_s) }

  before :all do
    @folder = Tmp::Folder.new('source/local')
    @path_a, @spec_a = tmp_package 'a', '1.0.0', destination: @folder.to_s
    @path_a2, @spec_a2 = tmp_package 'a', '2.0.0', destination: @folder.to_s
    @path_ap, @spec_ap = tmp_package 'a', '2.1.0-alpha', destination: @folder.to_s
    @path_b, @spec_b = tmp_package 'b', '1.0.0', destination: @folder.to_s
  end

  describe '#load_specs' do
    it 'load specs of release' do
      expect(subject.load_specs(:released).sort).to eq([@spec_a.name_tuple, @spec_a2.name_tuple, @spec_b.name_tuple].sort)
    end

    it 'load specs of prerelease' do
      expect(subject.load_specs(:prerelease)).to eq([@spec_ap.name_tuple])
    end
    it 'get only the latest release version' do
      expect(subject.load_specs(:latest_release).sort).to eq([@spec_a2.name_tuple, @spec_b.name_tuple].sort)
    end
    it 'get only the latest version' do
      expect(subject.load_specs(:latest).sort).to eq([@spec_ap.name_tuple, @spec_b.name_tuple].sort)
    end
  end

  describe '#find_package' do
    context 'when finding by name' do
      let (:spec) { subject.find_package('a') }
      it { expect(spec.name).to eq('a') }
      it { expect(spec.version.to_s).to eq('2.0.0') }
    end
    context 'when finding by name and version' do
      let (:spec) { subject.find_package('a', '1.0.0') }
      it { expect(spec.name).to eq('a') }
      it { expect(spec.version.to_s).to eq('1.0.0') }
    end

    context 'when finding by name and including prerelease' do
      let (:spec) { subject.find_package('a', prerelease: true) }
      it { expect(spec.name).to eq('a') }
      it { expect(spec.version.to_s).to eq('2.1.0.a') }
    end
  end

  describe '#fetch_spec' do
    it 'fetch spec' do
      s = subject.fetch_spec @spec_a.name_tuple
      expect(s).to eq (@spec_a)
    end
  end

  describe '#download' do
    it { expect(subject.download @spec_a).to eq(File.expand_path(@path_a)) }
  end

end