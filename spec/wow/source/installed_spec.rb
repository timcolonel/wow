require 'spec_helper'
require 'wow/source/installed'

RSpec.describe Wow::Source::Installed do
  subject { Wow::Source::Installed.new(@folder.to_s) }

  before :all do
    @folder = Tmp::Folder.new('source/installed')
    @install_dir = Wow::InstallDir.new(@folder.to_s)
    @folder.sub_folder('lib')
    @pkg_a = tmp_package 'a', '1.0.0', extract_to: @install_dir.lib
    @pkg_a2 = tmp_package 'a', '2.0.0', extract_to: @install_dir.lib
    @pkg_ap = tmp_package 'a', '2.1.0-alpha', extract_to: @install_dir.lib
    @pkg_b = tmp_package 'b', '1.0.0', extract_to: @install_dir.lib
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
end