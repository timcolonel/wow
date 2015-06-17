require 'spec_helper'
require 'wow/commands/init'

RSpec.describe Wow::Command::Init do
  let (:folder) { Tmp::Folder.new('command_init') }
  let(:toml_file) { folder.path('wow.toml') }
  describe '#run' do
    subject { Wow::Command::Init.new }
    change_dir { folder }

    it 'create the file when it does not exists' do
      subject.run
      expect(File).to exist(toml_file)
    end

    it 'does not create the file when it exist and user ask to keep' do
      File.open toml_file, 'w' do |f|
        f.write 'content'
      end
      expect(subject.shell).to receive(:keep?).with(toml_file).and_return(true)
      subject.run
      expect(File.read(toml_file)).to eq('content')
    end

    it 'does not create the file when it exist and user ask to keep' do
      File.open toml_file, 'w' do |f|
        f.write 'content'
      end
      expect(subject.shell).to receive(:keep?).with(toml_file).and_return(false).and_yield
      subject.run
      expect(File.read(toml_file)).not_to eq('content')
    end
  end
end
