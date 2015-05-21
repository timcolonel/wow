require 'spec_helper'
require 'wow/api_client'

RSpec.describe Wow::Archive do
  let (:folder) { Tmp::Folder.new ('test_archive') }

  context 'archive is created' do
    let (:filenames) { folder.create_files(count: 5) }
    let (:base_filename) { filenames.map { |x| File.basename(x) } }
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
        it { expect { |b| archive.each(&b) }.to raise_error(Wow::Error) }
      end
    end

    describe '#open_file' do
      subject (:archive) { Wow::Archive.open(archive_name) }

      it 'seek a file and read the content without extracting' do
        archive.open_file base_filename[0] do |f|
          expect(f.read).to eq (File.read(filenames[0]))
        end
      end

      context 'when archive is open in write mode' do
        subject (:archive) { Wow::Archive.write(archive_name) }
        after { subject.close }
        it { expect { |b| archive.open_file(base_filename[0], &b) }.to raise_error(Wow::Error) }
      end
    end

    describe '#read_file' do
      subject (:archive) { Wow::Archive.open(archive_name) }

      it 'seek a file and read the content without extracting' do
        expect(archive.read_file(base_filename[1])).to eq (File.read(filenames[1]))
      end
    end
  end
end