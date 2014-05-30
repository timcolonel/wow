module Wow
  module Config
    class << self
      attr_accessor :install_folder

      def load
        @install_folder = 'install'
      end
    end
  end
end

Wow::Config.load