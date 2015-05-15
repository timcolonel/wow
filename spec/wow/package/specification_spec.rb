require 'spec_helper'
require 'wow/package/specification'

def asset(path)
  File.join(File.dirname(__FILE__), 'assets', path)
end

RSpec.describe Wow::Package::Specification do
  let (:folder) { 'test_package_config' }
  before :each do
    change_asset_folder(File.expand_path('../assets', __FILE__))
  end

  describe '#init_from_toml' do
    subject { Wow::Package::Specification.new }

    it 'load toml file' do
      hash = {name: 'Some name', version: '1.2.3', author: 'Some author'}
      tmp = TmpFile.path('package.toml', self.folder)
      erb = Renderer::ERB.render_file(asset('package_config.toml.erb'), hash)
      File.write(tmp, erb)
      subject.init_from_toml(tmp)
      expect(subject.name).to eq(hash[:name])
      expect(subject.version).to eq(hash[:version])
      expect(subject.authors).to include(hash[:author])
    end
  end

  describe '#files' do
    subject { Wow::Package::Specification.new }
    it 'list files with pattern' do
      subject.file 'assets/*.*'
      expect(subject.files.keys).to include('assets/platforms.yml')
    end

    it 'list file in folder' do
      subject.file 'assets/'
      expect(subject.files.keys).to include('assets/platforms.yml')
    end
  end

  describe '#valid?' do
    subject do
      config = Wow::Package::Specification.new
      config.version = '1.0.0'
      config.name = 'some-name'
      config.file 'some/file.txt'
      config
    end

    it { expect(subject).to be_valid }

    context 'when name is empty' do
      before { subject.name = nil }
      it { expect(subject).not_to be_valid }
    end

    context 'when name is invalid' do
      before { subject.name = 'some wrong name' }
      it { expect(subject).not_to be_valid }
    end

    context 'when name is invalid' do
      before { subject.name = 'some wrong name' }
      it { expect(subject).not_to be_valid }
    end

    context 'when version is empty' do
      before { subject.version = nil }
      it { expect(subject).not_to be_valid }
    end

    context 'when file contains absolute path' do
      before { subject.file '/absolute/path' }
      it { expect(subject).not_to be_valid }
    end
  end

  describe '#create_archive' do
    subject do
      config = Wow::Package::Specification.new
      config.name = 'from_archive'
      config.version = '1.0.0'
      filenames = TmpFile.create_files(count: 5, :folder => File.join(folder, 'input'), absolute: false)
      config.file filenames
      config
    end

    let (:archive) { subject.create_archive(TmpFile.folder_path(folder)) }

    it 'archive file should exists' do
      expect(File).to exist(archive)
    end
  end

  describe '#install_to' do
    let (:filenames) { TmpFile.create_files(count: 5, :folder => File.join(folder, 'input'), absolute: false) }
    let (:destination) { File.join(TmpFile.folder_path(folder), 'output') }
    subject do
      config = Wow::Package::Specification.new
      config.name = 'from_archive'
      config.version = '1.0.0'
      config.file filenames
      config
    end

    it 'files should be installed' do
      subject.install_to(destination)
      subject.files.each do |_, filename|
        expect(File).to exist(File.join(destination, filename))
      end
    end
  end

  describe '#package_folder' do
    let (:name) { Faker::App.name }
    let (:version) { '1.2.3' }

    subject do
      config = Wow::Package::Specification.new
      config.name = name
      config.version = version
      config
    end

    it { expect(subject.package_folder).to eq("#{name}-#{version}") }

    context 'when platform is specified' do
      let (:platform) { :unix }
      before { subject.platform = platform }

      it { expect(subject.package_folder).to eq("#{name}-#{version}-#{platform}") }
    end
  end
end
