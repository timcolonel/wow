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

  describe '#glob_packages' do
    it 'load specs of release' do
      expect(subject.glob_packages.keys.sort)
        .to eq([@pkg_a, @pkg_a2, @pkg_ap, @pkg_b].map(&:name_tuple).sort)
    end
  end
end
