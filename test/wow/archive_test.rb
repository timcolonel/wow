require 'test/test_helper'

class Wow::ArchiveTest < ActiveSupport::TestCase
  def setup
    TmpFile.clean folder
  end

  def folder
    'test_archive'
  end

  def create_archive(filename = 'archive.tar.gz')
    archive = TmpFile.path(filename, folder)
    filenames = TmpFile.create_files(:count => 5, :folder => 'test_archive')
    Wow::Archive.create(filenames, archive)
    return archive, filenames
  end

  test 'Should create an archive then extract successfully' do
    archive, filenames = create_archive

    assert File.exist?(archive), "Archive `#{archive}` should exist but doesn't"

    output_folder = TmpFile.path('output', folder)
    Wow::Archive.extract(archive, output_folder)

    filenames.each do |filename|
      output_file = File.join(output_folder, File.basename(filename))
      assert File.exist?(output_file), "Archive file `#{output_file}` should exist but doesn't"
    end
  end

  test 'Should iterate throught archive file when reading' do
    archive_file, filenames = create_archive
    assert_nothing_raised do
      Wow::Archive.open archive_file do |archive|
        count = 0
        archive.each do |entity|
          assert filenames.map { |x| File.basename(x) }.include?(entity.full_name)
          count += 1
        end
        assert count == filenames.size, "Should be #{filenames.size} but there is #{count}"
      end
    end
  end

  test 'Opening in write mode should fail' do
    archive_file = TmpFile.path('archive.tar.gz', folder)
    assert_raise WowError do
      Wow::Archive.write archive_file do |archive|
        archive.each do |entity|
          #Should have failed
        end
      end
    end
  end
end