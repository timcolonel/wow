require 'spec_helper'
require 'wow/api_client'

RSpec.describe Wow::ApiClient do
  describe '#current_source=' do
    let (:new_source) { Faker::Internet.url }
    subject do
      client = Wow::ApiClient.new
      client.sources = {some: new_source}
      client
    end

    it 'set source with key' do
      subject.current_source = :some
      expect(subject.current_source).to eq(new_source)
    end

    it 'set source with url' do
      subject.current_source = new_source
      expect(subject.current_source).to eq(new_source)
    end
  end
end