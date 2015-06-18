require 'spec_helper'
require 'wow/package/specification'

def asset(path)
  File.join(File.dirname(__FILE__), 'assets', path)
end

RSpec.describe Wow::Package::Specification do
  let(:folder) { Tmp::Folder.new('package_spec') }

  describe '.from_toml' do
    let(:hash) { {name: 'Some name', version: '1.2.3', author: 'Some author'} }
    let(:filename) do
      tmp = folder.path('package.toml')
      erb = Renderer::ERB.render_file(asset('package_config.toml.erb'), hash)
      File.write(tmp, erb)
      tmp
    end
    subject { Wow::Package::Specification.from_toml(filename) }

    it { expect(subject.name).to eq(hash[:name]) }
    it { expect(subject.version).to eq(Wow::Package::Version.parse(hash[:version])) }
    it { expect(subject.authors).to include(hash[:author]) }
  end

  describe '#files' do
    subject { Wow::Package::Specification.new }
    it 'list files with pattern' do
      subject.file 'assets/*.*'
      expect(subject.files.keys).to include('assets/targets.yml')
    end

    it 'list file in folder' do
      subject.file 'assets/'
      expect(subject.files.keys).to include('assets/targets.yml')
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
  end

  describe '#create_archive' do
    subject do
      config = Wow::Package::Specification.new
      config.name = Faker::Lorem.word
      config.version = '1.0.0'
      filenames = folder.sub_folder('input').create_files(count: 5, absolute: false)
      config.file filenames
      config
    end
    let(:destination) { folder.sub_folder('archive_dst') }
    change_dir { destination }

    let(:archive) { subject.create_archive(:any, destination: folder.to_s) }

    it 'archive file should exists' do
      expect(File).to exist(archive)
    end
  end

  describe '#install_to' do
    let(:filenames) { folder.sub_folder('input').create_files(count: 5, absolute: false) }
    let(:destination) { folder.sub_folder('output') }
    change_dir { folder }
    subject do
      config = Wow::Package::Specification.new
      config.name = Faker::Lorem.word
      config.version = '1.0.0'
      config.file filenames
      config
    end

    it 'files should be installed' do
      subject.install_to(:any, destination: destination.to_s)
      subject.files.each do |_, filename|
        expect(File).to exist(File.join(destination, filename))
      end
    end
  end

  describe '#lock' do
    before do
      allow_any_instance_of(Wow::Package::Specification).to receive(:files) do |spec|
        Hash[spec.files_included.map(&:wildcard).map { |x| [x, x] }]
      end
    end

    # Sort a json object so array don't need to
    def sort_json(json)
      out = {}
      json.each do |k, v|
        if v.is_a? Hash
          v = sort_json(v)
        elsif v.respond_to?(:sort)
          v = v.sort_by(&:to_s)
        end
        out[k] = v
      end
      out
    end

    it 'run the test cases' do
      Dir.chdir(File.join(File.dirname(__FILE__), 'cases/specification')) do
        Dir['*.toml'].each do |spec_file|
          base = File.basename(spec_file, '.toml')
          spec = Wow::Package::Specification.from_toml(spec_file)
          Dir["#{base}*.json"].each do |json_file|
            json_base = File.basename(json_file, '.json')
            match = json_base.match(/\A#{Regexp.escape(base)}-([a-z0-9]+)(?:-([a-z0-9]+))?\Z/)
            platform = match[1]
            architecture = match[2]
            message = "Error in creating the lock file for #{platform} #{architecture}"
            out = spec.lock(platform, architecture).as_json
            should = JSON.parse(File.read(json_file), symbolize_names: true)
            expect(sort_json(out)).to eq(sort_json(should)), message
          end
        end
      end
    end
  end
end
