require 'spec_helper'
require 'wow/package/file_pattern'

def test_split_pattern(root, wildcard)
  pattern = File.join(root, wildcard)
  result = Wow::Package::FilePattern.split_pattern(pattern)
  expect(result[0]).to eq(root)
  expect(result[1]).to eq(wildcard)
end

RSpec.describe Wow::Package::FilePattern do
  describe '#initalize' do
    it 'create a file pattern with 2 arguments' do
      pattern = 'lib/**/*'
      destination = 'dist'
      p = Wow::Package::FilePattern.new(pattern, destination)
      expect(p.pattern).to eq(pattern)
      expect(p.destination).to eq(destination)
    end

    it 'create file pattern from hash' do
      pattern = {:'lib/**/*' => 'dist'}
      p = Wow::Package::FilePattern.new(pattern)
      expect(p.pattern).to eq(pattern.first[0].to_s)
      expect(p.destination).to eq(pattern.first[1])
    end

    it 'create file pattern from hash string format' do
      pattern = 'lib/**/*'
      destination = 'dist'
      p = Wow::Package::FilePattern.new("#{pattern} => #{destination}")
      expect(p.pattern).to eq(pattern)
      expect(p.destination).to eq(destination)
    end

    it 'create file pattern and split root/wildcard' do
      pattern = 'lib/**/*'
      destination = 'dist'
      p = Wow::Package::FilePattern.new(pattern, destination)
      expect(pattern).to eq(p.pattern)
      expect('lib').to eq(p.root)
      expect('**/*').to eq(p.wildcard)
      expect(destination).to eq(p.destination)
    end
  end

  describe '.split_pattern' do
    it 'split pattern' do
      test_split_pattern '/absolute', 'path'
      test_split_pattern 'lib', '**/*'
      test_split_pattern 'lib', '*'
      test_split_pattern 'lib/sub', '**/*'
      test_split_pattern 'lib', '**/*.rb'
    end
  end

  describe '#pattern=' do
    it 'it work with only a file' do
      pattern = 'somefile.txt'
      p = Wow::Package::FilePattern.new(pattern)
      expect(pattern).to eq(p.pattern)
    end

    it 'it work with only a file and folder structure' do
      pattern = 'some/somefile.txt'
      p = Wow::Package::FilePattern.new(pattern)
      expect(pattern).to eq(p.pattern)
    end
  end

  describe '#file_map' do
    dir = File.dirname(__FILE__)
    context 'when pattern is a single file' do
      pattern = 'assets/targets.yml'

      let (:map) { Wow::Package::FilePattern.new(pattern).file_map(dir) }

      it 'should have only 1 result' do
        expect(map.size).to eq(1)
      end

      it 'destination should be the same as source' do
        src, dst = map.first
        expect(dst).to eq(src)
      end

      it 'source should be a existing file' do
        src = map.first.first
        expect(File).to exist(File.join(dir, src))
      end
    end

    context 'when pattern is a wildcard' do
      pattern = 'assets/**/*'

      context 'when destination is NOT specified' do
        let (:map) { Wow::Package::FilePattern.new(pattern).file_map(dir) }
        it 'destination file equal source' do
          map.each do |src, dst|
            expect(dst).to eq(src)
          end
        end
        it 'source should exist' do
          map.each do |src, dst|
            expect(File).to exist(File.join(dir, src))
          end
        end
      end

      context 'when destination is specified' do
        destination = 'dist'
        let (:map) { Wow::Package::FilePattern.new(pattern, destination).file_map(dir) }

        it 'destination is different from source' do
          map.each do |src, dst|
            expect(dst).not_to eq(src)
          end
        end
        it 'destination file is in the destination dir' do
          map.each do |_, dst|
            expect(dst).to start_with(destination)
          end
        end
      end
    end
  end
end
