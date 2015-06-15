require 'spec_helper'

RSpec.describe Wow::SourceList do
  let(:folder) { Tmp::Folder.new('source_list') }
  describe '#<<' do
    it 'add a new source' do
      source = Wow::Source.new(folder.to_s)
      subject << source
      expect(subject.sources).to eq [source]
    end

    it 'add a new source using a string' do
      source = folder.to_s
      subject << source
      expect(subject.sources).to eq [Wow::Source::Local.new(source)]
    end
  end

  describe '#replace' do
    it 'replace the content with an array' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      subject.replace([folder.to_s])
      expect(subject.sources).to eq [Wow::Source::Local.new(folder.to_s)]
    end

    it 'replace the content with another sourcelist' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      new_list = [Wow::Source.new('/newpath1')]
      subject.replace(new_list)
      expect(subject.sources).to eq new_list
    end

    it 'replace the source in places' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      new_list = [Wow::Source.new('/newpath1')]
      sources = subject.sources
      subject.replace(new_list)
      expect(sources).to eq new_list
    end
  end

  describe '#clear' do
    it 'replace clear the sources' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      subject.clear
      expect(subject.sources).to eq []
    end

    it 'replace clear in place' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      sources = subject.sources
      subject.clear
      expect(sources).to eq []
    end
  end

  describe '#each' do
    it 'iterate each source' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      expect { |b| subject.each(&b) }.to yield_successive_args(subject.sources[0], subject.sources[1])
    end
  end

  describe '#empty' do
    it 'is empty when source is empty' do
      expect(subject).to be_empty
    end

    it 'is not empty when source is not empty' do
      subject << Wow::Source.new('/path1')
      expect(subject).not_to be_empty
    end
  end

  describe '#==' do
    it 'equal other source list' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')

      other = Wow::SourceList.new
      other << Wow::Source.new('/path1')
      other << Wow::Source.new('/path2')
      expect(subject).to eq(other)
    end

    it 'does not equal other source list' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')

      other = Wow::SourceList.new
      other << Wow::Source.new('/path1')
      expect(subject).not_to eq(other)
    end
  end

  describe '#to_a' do
    it 'return array of string' do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
      expect(subject.to_a).to eq(%w(/path1 /path2))
    end
  end

  describe '#include?' do
    before do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
    end

    it { expect(subject).to include('/path1') }
    it { expect(subject).to include(Wow::Source.new('/path2')) }
    it { expect(subject).not_to include('/path3') }
    it { expect(subject).not_to include(Wow::Source.new('/path3')) }
  end

  describe '#delete?' do
    before do
      subject << Wow::Source.new('/path1')
      subject << Wow::Source.new('/path2')
    end

    it 'delete with string' do
      subject.delete('/path1')
      expect(subject.sources).to eq([Wow::Source.new('/path2')])
    end

    it 'delete with source' do
      subject.delete(Wow::Source.new('/path2'))
      expect(subject.sources).to eq([Wow::Source.new('/path1')])
    end
  end

  describe '#list_packages' do
    let(:source1) { Wow::Source.new('/path1') }
    let(:source2) { Wow::Source.new('/path2') }
    before do
      allow(source1).to receive(:list_packages).and_return([:pkg1, :pkg2])
      allow(source2).to receive(:list_packages).and_return([:pkg3, :pkg4])
      subject << source1
      subject << source2
      @packages = subject.list_packages('a', '>= 1.0.0', prerelease: true)
    end

    it { expect(source1).to have_received(:list_packages).with('a', '>= 1.0.0', prerelease: true) }
    it { expect(source2).to have_received(:list_packages).with('a', '>= 1.0.0', prerelease: true) }
    it { expect(@packages).to eq([:pkg1, :pkg2, :pkg3, :pkg4]) }
  end

  describe '#get_packages' do
    let(:pkg1) { double(:package1, spec: double(:spec, version: 1)) }
    let(:pkg2) { double(:package2, spec: double(:spec, version: 2)) }
    let(:source1) { Wow::Source.new('/path1') }
    let(:source2) { Wow::Source.new('/path2') }
    before do
      allow(source1).to receive(:find_package).and_return(pkg1)
      allow(source2).to receive(:find_package).and_return(pkg2)
      subject << source1
      subject << source2
    end
    it { expect(subject.find_package('a', '>= 1.0.0', first_match: false)).to eq(pkg2) }
    it { expect(subject.find_package('a', '>= 1.0.0', first_match: true)).to eq(pkg1) }
    it { expect(subject.find_package('a', '>= 1.0.0')).to eq(pkg1) }
  end
end
