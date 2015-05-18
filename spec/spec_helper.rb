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
  config.extend Macros

  config.order = 'random'

end
