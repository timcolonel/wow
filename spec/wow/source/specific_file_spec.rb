require 'spec_helper'
require 'wow/source/specific_file'

RSpec.describe Wow::Source::SpecificFile do
  subject { Wow::Source::SpecificFile.new(@pkg.path.to_s) }

  before :all do
    @folder = Tmp::Folder.new('source/specific_file')
    @pkg = tmp_package 'a', '1.0.0', destination: @folder.to_s
  end
  it { expect(subject.path).to eq(@pkg.path) }

  describe '#load_specs' do
    it { expect(subject.list_packages).to be_a Array }
    it { expect(subject.list_packages).to eq([@pkg.spec.name_tuple]) }
  end

  describe '#fetch_spec' do
    it { expect(subject.fetch_spec(@pkg.spec.name_tuple)).to eq(@pkg.spec) }
  end

  describe '#download' do
    it { expect(subject.download @pkg.spec).to eq(File.expand_path(@pkg.path)) }
  end

end