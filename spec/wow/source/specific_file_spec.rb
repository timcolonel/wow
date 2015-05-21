require 'spec_helper'
require 'wow/source/specific_file'

RSpec.describe Wow::Source::SpecificFile do
  subject { Wow::Source::SpecificFile.new(@path.to_s) }

  before :all do
    @folder = Tmp::Folder.new('source/specific_file')
    @path, @spec = tmp_package 'a', '1.0.0', destination: @folder.to_s
  end
  it { expect(subject.path).to eq(@path) }

  describe '#load_specs' do
    it { expect(subject.load_specs).to be_a Array }
    it { expect(subject.load_specs).to eq([@spec.name_tuple]) }
  end

  describe '#fetch_spec' do
    it { expect(subject.fetch_spec(@spec.name_tuple)).to eq(@spec) }
  end

  describe '#download' do
    it { expect(subject.download @spec).to eq(File.expand_path(@path)) }
  end

end