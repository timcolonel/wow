require 'test/test_helper'

class Wow::ArchiveTest < ActiveSupport::TestCase
  class TmpSub
    def run
      'Installing'
    end
  end

  test 'Test Should call right method' do
    Wow::Command.class_eval do
      def install
        return TmpSub.new
      end
    end
    assert_nothing_raised Wow::UnknownCommand do
      assert_equal 'Installing', Wow::Command.new('install' => true).run
    end
  end


  test 'Aliases should work' do
    Wow::Command.class_eval do
      def install
        return TmpSub.new
      end
    end
    assert_nothing_raised Wow::UnknownCommand do
      assert_equal 'Installing', Wow::Command.new('instal' => true).run
    end
  end

  test 'init should copy the template toml file' do
    cwd = Tmp::Folder.new('test_init')
    Dir.chdir cwd.fullpath do
      Wow::Command.new('init' => true).run
      assert File.exist?(cwd.path('wow.toml'))
    end
  end
end