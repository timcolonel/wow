require 'spec_helper'
require 'wow/package_resolver'

RSpec.describe Wow::PackageResolver do
  before :all do
    @folder = Tmp::Folder.new('package_resolver')
    @local_source = Wow::Source::Local.new(@folder.to_s)
    @installed_source = Wow::Source::Installed.new(@folder.to_s)

    Wow.sources.clear
    Wow.installed_sources.clear
    Wow.sources << @local_source
    Wow.installed_sources << @installed_source

    @pkg_a = tmp_package 'a', '1.0.0'
    @pkg_a2 = tmp_package 'a', '2.0.0'
  end

  describe '#get_package' do
    context 'when package is not found' do
      subject { Wow::PackageResolver.new(:install) }

      it { expect { subject.get_package('some') }.to raise_error(Wow::Error) }
    end

    context 'when package is not installed' do
      before do
        @pkg_a.source = @local_source
        allow(@local_source).to receive(:glob_packages).and_return({@pkg_a.spec.name_tuple => @pkg_a})
      end
      context 'when installing ' do
        subject { Wow::PackageResolver.new(:install) }

        it { expect(subject.get_package('a').spec).to eq(@pkg_a.spec) }
        it { expect(subject.get_package('a').source).to eq(@local_source) }
      end
      context 'when updating' do
        subject { Wow::PackageResolver.new(:update) }

        it { expect(subject.get_package('a').spec).to eq(@pkg_a.spec) }
        it { expect(subject.get_package('a').source).to eq(@local_source) }

      end
    end

    context 'when package is installed' do
      before do
        @pkg_a.source = @installed_source
        @pkg_a2.source = @local_source
        allow(@installed_source).to receive(:glob_packages).and_return({@pkg_a.spec.name_tuple => @pkg_a})
        allow(@local_source).to receive(:glob_packages).and_return({@pkg_a2.spec.name_tuple => @pkg_a2})
      end

      context 'when installing ' do
        subject { Wow::PackageResolver.new(:install) }

        it { expect(subject.get_package('a').spec).to eq(@pkg_a.spec) }
        it { expect(subject.get_package('a').source).to eq(@installed_source) }
      end

      context 'when updating' do
        subject { Wow::PackageResolver.new(:update) }

        it { expect(subject.get_package('a').spec).to eq(@pkg_a2.spec) }
        it { expect(subject.get_package('a').source).to eq(@local_source) }
      end
    end

    context 'when same package name is defined at multiple source' do
      before do
        @local_source2 = Wow::Source::Local.new(@folder.to_s)
        Wow.sources << @local_source2

        @pkg_a.source = @local_source
        @pkg_a2.source = @local_source2
        allow(@installed_source).to receive(:glob_packages).and_return({@pkg_a.spec.name_tuple => @pkg_a})
        allow(@local_source).to receive(:glob_packages).and_return({@pkg_a2.spec.name_tuple => @pkg_a2})
      end

      subject { Wow::PackageResolver.new(:install) }
      it 'get the first package found in the order of repository' do
        expect(subject.get_package('a').spec).to eq(@pkg_a.spec)
        expect(subject.get_package('a').source).to eq(@local_source)
      end
    end
  end
end
