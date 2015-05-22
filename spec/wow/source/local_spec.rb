require 'spec_helper'
require 'wow/source/local'

RSpec.describe Wow::Source::Local do
  subject { Wow::Source::Local.new(@folder.to_s) }

  before :all do
    @folder = Tmp::Folder.new('source/local')
    @pkg_a = tmp_package 'a', '1.0.0', destination: @folder.to_s
    @pkg_a2 = tmp_package 'a', '2.0.0', destination: @folder.to_s
    @pkg_ap = tmp_package 'a', '2.1.0-alpha', destination: @folder.to_s
    @pkg_b = tmp_package 'b', '1.0.0', destination: @folder.to_s
  end

  describe '#list_packages' do
    it 'load specs of release' do
      expect(subject.list_packages(:released).sort).to eq([@pkg_a.spec.name_tuple, @pkg_a2.spec.name_tuple, @pkg_b.spec.name_tuple].sort)
    end

    it 'load specs of prerelease' do
      expect(subject.list_packages(:prerelease)).to eq([@pkg_ap.spec.name_tuple])
    end
    it 'get only the latest release version' do
      expect(subject.list_packages(:latest_release).sort).to eq([@pkg_a2.spec.name_tuple, @pkg_b.spec.name_tuple].sort)
    end
    it 'get only the latest version' do
      expect(subject.list_packages(:latest).sort).to eq([@pkg_ap.spec.name_tuple, @pkg_b.spec.name_tuple].sort)
    end
  end

  describe '#find_package' do
    context 'when finding by name' do
      let (:package) { subject.find_package('a') }
      let (:spec) { package.spec }
      it { expect(package.source).to eq(subject) }
      it { expect(spec.name).to eq('a') }
      it { expect(spec.version.to_s).to eq('2.0.0') }
    end
    context 'when finding by name and version' do
      let (:package) { subject.find_package('a', '1.0.0') }
      let (:spec) { package.spec }
      it { expect(spec.name).to eq('a') }
      it { expect(spec.version.to_s).to eq('1.0.0') }
    end

    context 'when finding by name and including prerelease' do
      let (:package) { subject.find_package('a', prerelease: true) }
      let (:spec) { package.spec }
      it { expect(spec.name).to eq('a') }
      it { expect(spec.version.to_s).to eq('2.1.0.a') }
    end
  end

  describe '#fetch_spec' do
    it 'fetch spec' do
      s = subject.fetch_spec @pkg_a.spec.name_tuple
      expect(s).to eq (@pkg_a.spec)
    end
  end

  describe '#download' do
    it { expect(subject.download @pkg_a.spec).to eq(File.expand_path(@pkg_a.path)) }
  end

end