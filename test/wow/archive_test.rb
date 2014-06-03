require 'test/test_helper'

class Wow::ArchiveTest < ActiveSupport::TestCase
  def setup
    TmpFile.clean folder
  end

  def folder
    'test_archive'
  end
  test 'Should create an archive then extract successfully' do
    archive = TmpFile.path('archive.tar.gz', folder)
    filenames = TmpFile.create_files(:count => 5, :folder => 'test_archive')
    Wow::Archive.create(filenames, archive)

    assert File.exist?(archive), "Archive `#{archive}` should exist but doesn't"

    output_folder = TmpFile.path('output', folder)
    Wow::Archive.extract(archive, output_folder)

    filenames.each do |filename|
      output_file = File.join(output_folder, File.basename(filename))
      assert File.exist?(output_file), "Archive file `#{output_file}` should exist but doesn't"
    end
  end

end