require 'test/test_helper'

class Wow::ArchiveTest < ActiveSupport::TestCase
  test 'Should create an archive' do
    output = TmpFile.path('archive.tar.gz', 'test_archive')
    filenames = TmpFile.create_files(:count => 5, :folder => 'test_archive')
    puts filenames
    Wow::Archive.create(filenames, output)

    assert File.exist?(output), "Archive `#{output}` should exist but doesn't"
  end
end