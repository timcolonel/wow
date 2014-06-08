module Wow
  module Package
    class Config
      attr_accessor :platform
      attr_accessor :files
      attr_accessor :executables

      def initialize
        @files = []
      end

      def file(files)
        @files += files
      end

      def executable(executables)
        @executables += executables
      end

      def platform(name, &block)
        
      end

      def +(config)
        fail ArgumentError unless config.is_a? Wow::Package::Config
        self.files += config.files
        self.executables += config.executables
        self
      end
    end
  end
end