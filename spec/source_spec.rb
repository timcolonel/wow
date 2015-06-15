require 'spec_helper'

RSpec.describe Wow::Source do
  describe '.for' do
    it 'create a local when source if a folder' do
      folder = Tmp::Folder.new
      source = Wow::Source.for(folder.to_s)
      expect(source).is_a?(Wow::Source::Local)
    end

    it 'create a specific file when source if a file' do
      folder = Tmp::Folder.new
      file = folder.new_file('pkg.wow')
      expect(Wow::Source::SpecificFile).to receive(:new).once.and_return(:specific_file)
      source = Wow::Source.for(file)
      expect(source).to eq(:specific_file)
    end

    it 'create a remote when source if a url' do
      source = Wow::Source.for('http://wow.com')
      expect(source).is_a?(Wow::Source::Remote)
    end

    it 'fail when invalid' do
      expect { Wow::Source.for('invalid+mre') }.to raise_error(ArgumentError)
    end
  end

  describe '#list_packages' do
    it 'should be implemented in inherited classes' do
      expect { Wow::Source.new('/path1').list_packages('a', '>= 1.0.0') }
        .to raise_error(NotImplementedError)
    end
  end

  describe '#find_packages' do
    let(:pkg1) { double(:package1, spec: double(:spec, version: 1)) }
    let(:pkg2) { double(:package2, spec: double(:spec, version: 2)) }
    let(:source) { Wow::Source.new('/path1') }
    it 'should be implemented in inherited classes' do
      expect(source).to receive(:list_packages)
                          .with('a', '>= 1.0.0', prerelease: true).and_return([pkg1, pkg2])

      expect(source.find_package('a', '>= 1.0.0', prerelease: true)).to eq(pkg2)
    end
  end

  describe '#==' do
    it { expect(Wow::Source.new('/path1')).to eq(Wow::Source.new('/path1')) }
    it { expect(Wow::Source.new('/path1')).not_to eq(Wow::Source.new('/path2')) }
    it { expect(Wow::Source.new('/path1')).not_to eq(true) }
  end
end
