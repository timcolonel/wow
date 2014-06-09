module Wow
  module Package
    class Config
      attr_accessor :platform
      attr_accessor :file_patterns
      attr_accessor :executables
      attr_accessor :platforms
      attr_accessor :platform_configs
      attr_accessor :name
      attr_accessor :version


      def initialize(platform = nil)
        @platform = Wow::Package::Platform.new(platform)
        @file_patterns = []
        @platforms = []
        @platform_configs = []
      end

      def file(files)
      end

      def executable(executables)
        @executables += executables
      end

      def platform(name, &block)
        platform_configs << {:plaform => Wow::Package::Platform.new(name), :block => block}
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
      def files
        results = []
        @file_patterns.each do |file_pattern|
          results += Dir.glob(file_pattern)
        end
        results
      end


      # @return [Boolean]
      # * true if this config has a platform spcified
      # * false if this config contains multiple platform(Just loaded from file)
      def plaform_specific?
        not platform.nil?
      end
    
      # Return the platform specific config
      # @return [Wow::Package::Config]
      def get_plaform_config(platform)
        config = Wow::Package::Config.new(platform)
        config.files = files
        platform_configs.each do |platform_config|
          if config.plaform.is? platform_config[:platform]
            config.instance_eval platform_config[:block]
          end
        end
        config
      end

      def validate!
        fail WowError, 'Name is not defined!' if name.nil? or name.empty?
        fail WowError, 'Version is not defined!' if name.nil? or name.empty?
      end

      def create_archive
        validate!
        filename = "#{@name}-#{@version}.wow"
        Archive.write filename do |archive|
          archive.add_files all_files
        end
      end
    end
  end
end