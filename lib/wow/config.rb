module Wow
  module Config
    class << self
      attr_accessor :install_folder

      def load
        @install_folder = 'install'
      end

      # Return the full path to the given file that should be on the root of the data folder
      # @param filename [String] Path to the filename from the root of the data folder
      # @return absoulte path from to this file
      def asset_path(filaname)
        File.join(Wow::Config::ASSET_FOLDER, filename)
      end
    end
  end
end

Wow::Config.load