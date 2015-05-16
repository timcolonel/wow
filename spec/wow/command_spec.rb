require 'spec_helper'
require 'wow/command'

RSpec.describe Wow::Archive do
  describe '#run' do
    let (:command) { 'install' }

    context 'when using command' do
      subject { Wow::Command.new(command => true) }
      let (:installer) { double('installer') }
      before do
        allow(installer).to receive(:run)
        allow(subject).to receive(command).and_return(installer)
        subject.run
      end
      it { expect(subject).to have_received(command) }
      it { expect(installer).to have_received(:run) }
    end
    context 'when using alias' do
      let (:alias_command) { 'instal' }
      subject { Wow::Command.new(alias_command => true) }
      let (:installer) { double('installer') }
      before do
        allow(installer).to receive(:run)
        allow(subject).to receive(command).and_return(installer)
        subject.run
      end
      it { expect(subject).to have_received(command) }
      it { expect(installer).to have_received(:run) }
    end
  end

  describe '#init' do
    subject { Wow::Command.new('init' => true) }

    before do
      allow_any_instance_of(Wow::Command::Init).to receive(:run)
      expect_any_instance_of(Wow::Command::Init).to receive(:run)
    end

    it 'call create an instance of init and call run' do
      subject.run
    end
  end
end