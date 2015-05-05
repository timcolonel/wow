require 'test/test_helper'

class Wow::ArchiveTest < ActiveSupport::TestCase

  test 'Test Should call right method' do
    Wow::Command.class_eval do
      def install
        return 'Installing'
      end
    end
    assert_nothing_raised Wow::UnknownCommand do
      assert_equal 'Installing', Wow::Command.new('install' => true).run
    end
  end

  test 'Aliases should work' do
    Wow::Command.class_eval do
      def install
        return 'Installing'
      end
    end
    assert_nothing_raised Wow::UnknownCommand do
      assert_equal 'Installing', Wow::Command.new('instal' => true).run
    end
  end
end