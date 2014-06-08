module Wow
  module Package
    class Config
      attr_accessor :platform
      attr_accessor :files
      attr_accessor :executables

      def initialize(platform = :any)
        @platform = platform
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

      def init_from_rb_file(file)
        File.open 'r' do |f|
          init_from_rb f.read
        end
      end

      def init_from_rb(ruby_str)
        self.instance_eval(ruby_str)
      end

      # @return all files matching the pattern given in the files
      def all_files
        results = []
        @files.each do |file_pattern|
          results += Dir.glob(file_pattern)
        end
        results
      end
    end
  end
end