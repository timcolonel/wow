require 'rubygems/package'

module Wow
  module Archive
    class << self
      def extract(filename, destination)
         Gem::Package::TarReader.new(Zlib::GzipReader.open(file.tempfile)) do |tar|
           tar.each do |tar_entity|
             destination_file = File.join destination, tarfile.full_name
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
      end

      def create(filenames, output)
        Zlib::GzipWriter.open(output) do |gz|
          io = StringIO.new('')
          tar = Gem::Package::TarWriter.new(io)
          [*filenames].each do |filename|
            mode = File.stat(filename).mode
            tar.add_file filename, mode do |tf|
              File.open(filename, 'rb') { |f| tf.write f.read }
            end
          end
          gz.write io.string
          tar.close
        end
      end
    end
  end
end