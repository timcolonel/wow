require 'coveralls'
Coveralls.wear!
$:.push File.expand_path('../../lib', __FILE__)
require 'active_support'
require 'active_support/testing/autorun'
require 'active_support/test_case'
require 'yaml'
require 'minitest/reporters'
require 'lib/wow'
require 'test/tmp_file'
require 'test/renderer'

MiniTest::Reporters.use!

class ActiveSupport::TestCase
  setup :setup_wow
  teardown :teardown_wow

  def change_asset_folder(folder)
    @asset_folder = Wow::Config::ASSET_FOLDER
    Wow::Config.send(:remove_const, :ASSET_FOLDER) if Wow::Config.const_defined?(:ASSET_FOLDER)
    Wow::Config.const_set(:ASSET_FOLDER, folder)
  end

  def teardown_wow
    if @asset_folder
      Wow::Config.send(:remove_const, :ASSET_FOLDER)
      Wow::Config.const_set(:ASSET_FOLDER, @asset_folder)
      @asset_folder = nil
    end
  end

  def setup_wow
  end

  def set_current_scenario(scenario)
  end
end

ActiveSupport::TestCase.test_order = :random