require 'rubygems/package'
require 'pathname'

module Wow
  class Archive
    MODES = [:read, :write]

    attr_accessor :mode
    attr_accessor :gz
    attr_accessor :io
    attr_accessor :tar_writer
    attr_accessor :tar_reader
    attr_accessor :filename

    # Open archive file to read
    # @param filename Archive filename
    # @param block Optional block the archive is given as param
    def self.open(filename, &block)
      archive = Archive.new
      archive.mode = :read
      archive.filename = filename
      archive.tar_reader = Gem::Package::TarReader.new(Zlib::GzipReader.open(filename))
      if block_given?
        block.call(archive)
        archive.tar_reader.close
      end
      archive
    end

    def self.write(filename, &block)
      archive = Archive.new
      archive.mode = :write
      archive.filename = filename
      archive.io = StringIO.new('')
      archive.gz = Zlib::GzipWriter.open(filename)
      archive.tar_writer = Gem::Package::TarWriter.new(archive.io)
      if block_given?
        block.call(archive)
        archive.close
      end
      archive
    end

    # Iterate through the file entity in the archive
    # @param block [Block] callback that will get an TarReader::Entry as argument
    def each (&block)
      if mode == :read
        tar_reader.each(&block)
      else
        fail Wow::Error, 'Must open archive in reading mode!'
      end
    end

    # Open a file for reading in the archive
    # @param filename [String] name of the file relative to the root of the archive
    # @param block [Block] Callback taking the file IO as argument
    # ```
    # archive.open_file 'file.txt' do |f|
    #   puts f.read
    # end
    # ```
    def open_file(filename, &block)
      fail Wow::Error, 'Must open archive in reading mode!' if mode != :read
      tar_reader.seek(filename, &block)
    end

    # Read the content of a file in the archive.
    # @param filename [String] name of the file relative to the root of the archive
    # ```
    # archive.read_file 'file.txt'
    # ```
    def read_file(filename)
      open_file filename do |f|
        return f.read
      end
    end

    # Close the archive file
    # Only needed if the open/write was called without a block
    def close
      unless gz.nil?
        gz.write io.string
        gz.close
      end
      tar_reader.close if tar_reader
    end

    # Add the given file to the archive
    # @params filename [String] name of the file to add
    # @params destination [String] name of the file(with path) in the archive
    def add_file(filename, destination = nil)
      mode = File.stat(filename).mode
      filename_in_archive = if destination
                              destination
                            elsif Pathname.new(filename).absolute?
                              File.basename(filename)
                            else
                              filename
                            end

      tar_writer.add_file filename_in_archive, mode do |tf|
        File.open(filename, 'rb') { |f|
          tf.write f.read
        }
      end
    end

    # Add the given list of files to the archive into the given folder
    # If the filenames are in an absolute path the file will be added to the root of the destination path
    # If the filename is a relative path it will be added relative to the destination path unless the flatten params is set to true 
    # @param file_map [Hash<String>] list of filenames to include in the archive
    # @param destination_path [String] folder where all of the file will be placed
    # @param flatten [Boolean] if set to true any relative files will be placed to the root of the destination path
    def add_files(file_map, destination_path: nil, flatten: false)
      file_map.each do |source, destination|
        # destination_filename = if Pathname.new(source).absolute? or flatten
        #                          File.basename(filename)
        #                        else
        #                          filename
        #                        end

        destination = File.join(destination_path, destination) if destination_path
        add_file source, destination
      end
    end

    def extract_all(destination)
      return false if tar_reader.nil?
      tar_reader.each do |tar_entity|
        destination_file = File.join destination, tar_entity.full_name
        if tar_entity.directory?
          FileUtils.mkdir_p destination_file
        else
          destination_directory = File.dirname(destination_file)
          FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
          File.open destination_file, 'wb' do |f|
            f.print tar_entity.read
          end
        end
      end
    end

    def self.extract(archive_filename, destination)
      Archive.open(archive_filename) do |archive|
        archive.extract_all(destination)
      end
    end

    def self.create(filenames, output)
      Archive.write(output) do |archive|
        archive.add_files filenames
      end
    end
  end
end