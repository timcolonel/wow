module Wow
  module Config
    ROOT_FOLDER = File.expand_path('../../..', __FILE__)
    ASSET_FOLDER = "#{Wow::Config::ROOT_FOLDER}/assets"

    class << self
      attr_accessor :package_install_root
      attr_accessor :remote


      def load
        @remote = 'http://localhost:3000'
        @package_install_root = File.join(ROOT_FOLDER, 'packages')
      end

      # Return the full path to the given file that should be on the root of the data folder
      # @param filename [String] Path to the filename from the root of the data folder
      # @return absolute path from to this file
      def asset_path(filename)
        File.join(Wow::Config::ASSET_FOLDER, filename)
      end

      def template_path(filename)
        File.join(Wow::Config::ASSET_FOLDER, 'templates', filename)
      end
    end

  end
end

Wow::Config.load