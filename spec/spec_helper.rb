require 'coveralls'
Coveralls.wear!
$:.push File.expand_path('../../lib', __FILE__)
require 'faker'
require 'rspec'
require 'active_support'
require 'active_support/testing/autorun'
require 'active_support/test_case'
require 'yaml'
require 'minitest/reporters'
require 'wow'
require 'tmp_file'
require 'renderer'

MiniTest::Reporters.use!


RSpec.configure do |config|
  config.include Helper
  config.order = 'random'

  config.after :all do
    if @asset_folder
      Wow::Config.send(:remove_const, :ASSET_FOLDER)
      Wow::Config.const_set(:ASSET_FOLDER, @asset_folder)
      @asset_folder = nil
    end
  end
end

module Helper
  def change_asset_folder(folder)
    @asset_folder = Wow::Config::ASSET_FOLDER
    Wow::Config.send(:remove_const, :ASSET_FOLDER) if Wow::Config.const_defined?(:ASSET_FOLDER)
    Wow::Config.const_set(:ASSET_FOLDER, folder)
  end
end

