require 'spec_helper'

RSpec.describe Wow::Package::SpecAttributes do
  let (:cls) { Class.new { include Wow::Package::SpecAttributes } }
  subject { cls.new }
  describe '#initialize_attributes' do
    it 'call each setter with nil' do
      subject._attrs.each do |attr|
        expect(subject).to receive("#{attr}=").with(nil)
      end
      subject.initialize_attributes
    end
  end

  describe '#replace_attributes' do
    let(:hash) { {name: 'new val', tags: %w(tag1 tag2)} }
    it 'call each setter with the value in the hash' do
      subject._attrs.each do |attr|
        expect(subject).to receive("#{attr}=").with(hash[attr])
      end
      subject.replace_attributes(hash)
    end

    it 'each attribute has been set with the value of the hash' do
      subject.replace_attributes(hash)
      expect(subject.name).to eq(hash[:name])
      expect(subject.tags).to eq(hash[:tags])
    end
  end

  describe '#assign_attributes' do
    let(:hash) { {name: 'new val', tags: %w(tag1 tag2)} }
    let(:summary) { Faker::Lorem.sentence }
    before do
      subject.summary = summary
    end
    it 'call each setter with the value in the hash' do
      subject._attrs.each do |attr|
        if hash.key? attr
          expect(subject).to receive("#{attr}=").with(hash[attr])
        else
          expect(subject).not_to receive("#{attr}=")
        end
      end
      subject.assign_attributes(hash)
    end

    it 'each value in the hash has been set and other kept' do
      subject.assign_attributes(hash)
      expect(subject.name).to eq(hash[:name])
      expect(subject.tags).to eq(hash[:tags])
      expect(subject.summary).to eq(summary)
    end
  end

  describe '#merge_attribute' do
    let(:other) { cls.new }
    let(:summary) { Faker::Lorem.sentence }
    before do
      other.name = 'new val'
      other.tags = %w(tag2 tag3)
      subject.summary = summary
      subject.tags = %w(tag1)
      subject.merge_attributes(other)
    end

    it { expect(subject.name).to eq(other.name) }
    it { expect(subject.tags).to eq(%w(tag1 tag2 tag3)) }
    it { expect(subject.summary).to eq(summary) }
  end

  describe '#attributes_hash' do
    let(:hash) do
      {
        name: 'new name',
        summary: 'summary of new',
        description: '',
        homepage: nil,
        authors: [],
        tags: %w(tag1 tag2),
        executables: [],
        applications: [],
        dependencies: Wow::Package::DependencySet.new,
        version: nil
      }
    end

    it do
      subject.initialize_attributes
      subject.name = 'new name'
      subject.summary = 'summary of new'
      subject.tags = %w(tag1 tag2)
      expect(subject.attributes_hash).to eq(hash)
    end
  end
end
