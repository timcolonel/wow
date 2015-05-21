require 'coveralls'
Coveralls.wear!
$:.push File.expand_path('../../lib', __FILE__)
require 'faker'
require 'rspec'
require 'active_support'
require 'yaml'
require 'wow'
require 'tmp_file'
require 'renderer'

module Helper

  # Create a tmp package archive
  def tmp_package(name, version, platform=nil, arch=nil, destination: nil)
    folder = Tmp::Folder.new('tmp_package', clean_first_only: true).sub_folder
    Dir.chdir folder.to_s do
      filenames = folder.create_files(count: 3, absolute: false)
      spec = Wow::Package::Specification.new
      spec.name = name
      spec.version = version
      spec.files_included = filenames.map { |x| Wow::Package::FilePattern.new(x) }
      archive_path = spec.create_archive(platform, arch, destination: folder.to_s)
      if destination
        FileUtils.mv archive_path, destination
        archive_path = File.join(destination, File.basename(archive_path))
      end
      return archive_path, spec.lock(platform, arch)
    end
  end
end


module Macros
  def change_dir(&block)
    around do |example|
      Dir.chdir instance_eval(&block).to_s do
        example.run
      end
    end
  end

  def change_asset_folder(&block)
    around do |example|
      # Set
      asset_folder = Wow::Config::ASSET_FOLDER
      Wow::Config.send(:remove_const, :ASSET_FOLDER) if Wow::Config.const_defined?(:ASSET_FOLDER)
      Wow::Config.const_set(:ASSET_FOLDER, instance_eval(&block).to_s)

      example.run

      # Cleanup
      Wow::Config.send(:remove_const, :ASSET_FOLDER)
      Wow::Config.const_set(:ASSET_FOLDER, asset_folder)
      Wow::Package::Platform.load
      @asset_folder = nil
    end
  end
end

RSpec.configure do |config|
  config.include Helper
  config.extend Macros

  config.order = 'random'

end
