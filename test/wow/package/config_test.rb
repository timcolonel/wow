require 'test/test_helper'

module Wow
  module Package
    class ConfigTest < ActiveSupport::TestCase

      def setup
        TmpFile.clean folder
      end

      def folder
        'test_package_config'
      end
      test 'should list all files' do
        config = Wow::Package::Config.new
        config.file_patterns << 'assets/*.*'
        assert_not config.files.empty?
        assert config.files.include? 'assets/platforms.yml'
      end

      test 'validate should fail without name' do
        config = Wow::Package::Config.new
        config.version = '1.0.0'
        assert_not config.valid?
      end

      test 'validate should fail with bad name' do
        config = Wow::Package::Config.new
        config.name = 'Bad name with space'
        config.version = '1.0.0'
        assert_not config.valid?
      end

      test 'validate should fail without version' do
        config = Wow::Package::Config.new
        config.name = 'super_name'
        assert_not config.valid?
      end

      test 'validate should fail with absolute path' do
        config = Wow::Package::Config.new
        config.name = 'super_name'
        config.version = '1.0.0'
        config.file_patterns << '/absolute/path'
        assert_not config.valid?
      end

      test 'validate should succeed' do
        config = Wow::Package::Config.new
        config.name = 'super_name'
        config.version = '1.0.0'
        config.file_patterns << 'relative/path'
        assert config.valid?, "Should be valid!, #{config.errors.full_messages}"
      end

      test 'should create archive from config' do
        config = Wow::Package::Config.new
        config.name = 'from_archive'
        config.version = '1.0.0'
        filenames = TmpFile.create_files(:count => 5, :folder => File.join(folder, 'input'), :absolute => false)
        config.file_patterns = filenames
        archive = config.create_archive(TmpFile.folder_path(folder))
        assert File.exists?(archive)
      end
      test 'should install to installation folder' do 
        config = Wow::Package::Config.new
        config.name = 'to_install'
        config.version = '1.0.0'
        filenames = TmpFile.create_files(:count => 5, :folder => File.join(folder, 'input'), :absolute => false)
        config.file_patterns = filenames
        destination = File.join(TmpFile.folder_path(folder), 'output')
        config.install_to(destination)
        filenames.each do |filename|
          assert File.exists?(File.join(Wow::Config::ROOT_FOLDER, filename)), "File #{filename} should exists in #{destination} but doesn't"
        end
      end
    end
  end
end