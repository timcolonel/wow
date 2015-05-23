require 'spec_helper'
require 'wow/command'

RSpec.describe Wow::Archive do
  describe '.parse_options' do
    context '' do
      let(:doc) { 'usage: wow <command>' }
      let(:cl) { 'install' }

      before do
        Wow::Command.doc = doc
      end
      it { expect(Wow::Command.parse_options(cl)).to eq('<command>' => cl) }
    end

    context 'when unknown options are authorized' do
      let(:doc) { 'usage: wow <command> <args>...' }
      let(:cl) { 'install --opt1 --opt2=val' }

      before do
        Wow::Command.doc = doc
        Wow::Command.authorize_unknown_options = true
      end
      it 'parse options as arguments' do
        expect(Wow::Command.parse_options(cl)).to eq('<command>' => 'install',
                                                     '<args>' => %w(--opt1 --opt2=val))
      end
    end
  end
end
