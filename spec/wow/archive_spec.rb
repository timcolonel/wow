require 'spec_helper'
require 'wow/api_client'

RSpec.describe Wow::Archive do
  let (:folder) { Tmp::Folder.new ('test_archive') }

  context 'archive is created' do
    let (:filenames) { folder.create_files(count: 5) }
    let (:archive_name) { folder.random(prefix: 'archive', extension: 'wow') }
    before do
      Wow::Archive.create(filenames, archive_name)
    end

    it { expect(File).to exist(archive_name) }

    context 'extracting archive' do
      let (:output_folder) { folder.path('output') }
      before do
        Wow::Archive.extract(archive_name, output_folder)
      end

      it 'should extract all the bundle file' do
        filenames.each do |filename|
          output_file = File.join(output_folder, File.basename(filename))
          expect(File).to exist(output_file), "Archive file `#{output_file}` should exist but doesn't"
        end
      end
    end

    describe '#each' do
      let (:base_filename) { filenames.map { |x| File.basename(x) } }

      context 'when archive is open is read mode' do
        subject (:archive) { Wow::Archive.open(archive_name) }
        after { subject.close }

        it { expect { |b| archive.each(&b) }.to yield_control.exactly(filenames.size).times }
        it {
          archive.each do |entity|
            expect(base_filename).to include(entity.full_name)
          end
        }
      end

      context 'when archive is open in write mode' do
        subject (:archive) { Wow::Archive.write(archive_name) }
        after { subject.close }
        it {expect { |b| archive.each(&b) }.to raise_error(Wow::Error)}
      end
    end
  end
end