require 'test/test_helper'

class Wow::ArchiveTest < ActiveSupport::TestCase
  class TmpSub
    def run
      'Installing'
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