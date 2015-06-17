require 'spec_helper'
require 'wow/package/specification_lock'

def asset(path)
  File.join(File.dirname(__FILE__), 'assets', path)
end

RSpec.describe Wow::Package::SpecificationLock do
  let (:folder) { Tmp::Folder.new('package_spec_lock') }

  describe '#filename' do
    let (:name) { Faker::App.name }
    before do
      subject.name = name
    end
    context 'when platform is any' do
      subject { Wow::Package::SpecificationLock.new(:any) }

      it { expect(subject.filename).to eq("#{name}.lock.json") }
    end

    context 'when platform is unix' do
      let (:platform) { :unix }
      subject { Wow::Package::SpecificationLock.new(platform) }

      it { expect(subject.filename).to eq("#{name}-#{platform}.lock.json") }
    end

    context 'when platform is uni and arch x64' do
      let (:platform) { :unix }
      let (:arch) { :x64 }
      subject { Wow::Package::SpecificationLock.new(platform, arch) }

      it { expect(subject.filename).to eq("#{name}-#{platform}-#{arch}.lock.json") }
    end
  end

  describe '#json' do
    let (:name) { Faker::App.name }
    let (:homepage) { Faker::Internet.url }
    let (:summary) { Faker::Lorem.sentence }

    subject do
      spec_lock = Wow::Package::SpecificationLock.new(:any)
      spec_lock.name = name
      spec_lock.version = '1.2.3'
      spec_lock.homepage = homepage
      spec_lock.tags = %w(my_tag1 my_tag2)
      spec_lock.summary = summary
      spec_lock.dependencies = {'otherpkg' => '>= 1.0.0'}
      spec_lock
    end
    let(:json) do
      {name: name,
       version: '1.2.3',
       homepage: homepage,
       tags: %w(my_tag1 my_tag2),
       authors: [],
       summary: summary,
       description: '',
       target: {platform: 'any', architecture: 'any'},
       files: [],
       executables: [],
       dependencies: [{name: 'otherpkg', version_range: '>= 1.0.0'}]}
    end
    it { expect(subject.as_json).to eq(json) }
  end

  describe '#save' do
    let (:name) { Faker::App.name }
    change_dir { folder }
    subject do
      spec_lock = Wow::Package::SpecificationLock.new(:any)
      spec_lock.name = name
      spec_lock.version = '1.2.3'
      spec_lock
    end

    before do
      subject.save
    end

    it { expect(File).to exist(subject.filename) }
  end
end
