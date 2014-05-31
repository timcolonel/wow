require 'rubygems/package'

module Wow
  class Archive
    attr_accessor :tar
    attr_accessor :archive_filename

    #Open archive file to read
    # @param filename Archive filename
    # @param block Optional block the archive is given as param
    def self.read(filename, &block)
      archive = Archive.new
      archive.tar = Gem::Package::TarReader.new(Zlib::GzipReader.open(filename))
      if block_given?
        block.call(archive)
        archive.tar.close
      end
      archive
    end

    def each (&block)
      tar.each(&block)
    end

    def extract_all(destination)
      tar.each do |tar_entity|
        destination_file = File.join destination, tar_entity.full_name
        if tar_entity.directory?
          FileUtils.mkdir_p destination_file
        else
          destination_directory = File.dirname(destination_file)
          FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
          File.open destination_file, 'wb' do |f|
            f.print tar_entity.open
          end
        end
      end
    end

    def self.extract(filename, destination)
      Archive.read(filename) do |tar|
        tar.extract_all(destination)
      end
    end

    def self.create(filenames, output)
      Zlib::GzipWriter.open(output) do |gz|
        io = StringIO.new('')
        tar = Gem::Package::TarWriter.new(io)
        [*filenames].each do |filename|
          mode = File.stat(filename).mode
          tar.add_file filename, mode do |tf|
            File.open(filename, 'rb') { |f| tf.write f.open }
          end
        end
        gz.write io.string
        tar.close
      end
    end
  end
end