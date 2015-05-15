require 'test/test_helper'
require 'wow/package/file_pattern'

def test_split_pattern(root, wildcard)
  pattern = File.join(root, wildcard)
  result = Wow::Package::FilePattern.split_pattern(pattern)
  assert_equal root, result[0]
  assert_equal wildcard, result[1]
end

module Wow
  module Package
    class FilePatternTest < ActiveSupport::TestCase
      test 'test create file pattern with both argument' do
        pattern = 'lib/**/*'
        destination = 'dist'
        p = Wow::Package::FilePattern.new(pattern, destination)
        assert_equal pattern, p.pattern
        assert_equal destination, p.destination
      end

      test 'test create file pattern fail with both argument and pattern being a hash' do
        destination = 'dist'
        pattern = {'lib/**/*' => destination}
        assert_raise ArgumentError do
          Wow::Package::FilePattern.new(pattern, destination)
        end
      end

      test 'test create file pattern with hash' do
        pattern = {'lib/**/*' => 'dist'}
        p = Wow::Package::FilePattern.new(pattern)
        assert_equal pattern.first[0], p.pattern
        assert_equal pattern.first[1], p.destination
      end

      test 'test create file pattern with hash in string' do
        pattern = 'lib/**/*'
        destination = 'dist'
        p = Wow::Package::FilePattern.new("#{pattern} => #{destination}")
        assert_equal pattern, p.pattern
        assert_equal destination, p.destination
      end


      test 'test split pattern' do
        test_split_pattern 'lib', '**/*'
        test_split_pattern 'lib', '*'
        test_split_pattern 'lib/sub', '**/*'
        test_split_pattern 'lib', '**/*.rb'
      end

      test 'test create file pattern wildcard and root extracted fine' do
        pattern = 'lib/**/*'
        destination = 'dist'
        p = Wow::Package::FilePattern.new(pattern, destination)
        assert_equal pattern, p.pattern
        assert_equal 'lib', p.root
        assert_equal '**/*', p.wildcard
        assert_equal destination, p.destination
      end

      test 'test file map is listing files with file as pattern' do
        pattern = 'assets/platforms.yml'
        dir = File.dirname(__FILE__)
        p = Wow::Package::FilePattern.new(pattern)
        map = p.file_map(dir)
        map.each do |src, dst|
          assert_equal src, dst
          assert File.exists? File.join(dir, src)
        end
      end

      test 'test file map is listing files' do
        pattern = 'assets/**/*'
        dir = File.dirname(__FILE__)
        p = Wow::Package::FilePattern.new(pattern)
        map = p.file_map(dir)
        map.each do |src, dst|
          assert_equal src, dst
          assert File.exists? File.join(dir, src)
        end
      end

      test 'test file map is listing files with destination' do
        pattern = 'assets/**/*'
        destination = 'dist'
        p = Wow::Package::FilePattern.new(pattern, destination)
        map = p.file_map(File.dirname(__FILE__))
        map.each do |src, dst|
          assert_not_equal src, dst
          assert dst.start_with?(destination)
        end
      end
    end
  end
end