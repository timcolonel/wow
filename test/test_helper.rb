require 'active_support'
require 'active_support/testing/autorun'
require 'active_support/test_case'
require 'yaml'
require 'minitest/reporters'
require 'lib/wow'
require 'test/tmp_file'
require 'coveralls'
Coveralls.wear!


MiniTest::Reporters.use!

class ActiveSupport::TestCase
  setup :setup_wow

  def setup_wow

  end

  def set_current_scenario(scenario)
  end
end