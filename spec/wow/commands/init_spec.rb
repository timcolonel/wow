require 'spec_helper'
require 'wow/commands/init'

RSpec.describe Wow::Command::Init do
  let (:folder) { Tmp::Folder.new('command_init') }
  describe '#run' do
    subject { Wow::Command::Init.new }

    # before { folder }
    change_dir { folder }

    before do
      subject.run
    end

    it { expect(File).to exist(folder.path('wow.toml')) }
  end
end