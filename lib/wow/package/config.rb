module Wow
  module Package
    class Config
      include ActiveModel::Validations

      attr_accessor :platform
      attr_accessor :file_patterns
      attr_accessor :executables
      attr_accessor :platforms
      attr_accessor :platform_configs
      attr_accessor :name
      attr_accessor :version

      validates_presence_of :name, :version
      validates_format_of :name, :with => /\A[a-z0-9_-]+\z/,
                          :message => 'Error in config file. Name should only contain lowercase, numbers and _-'

      validate do
        @file_patterns.each do |pattern|
          errors.add :file_patterns, 
            "Path `#{pattern}`should be relative to the root but is an absolute path!" if Pathname.new(pattern).absolute?
        end
      end

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

      # Raise am error if the config is invalid
      # @return [Boolean] true if succeed and raise WowError if not
      def validate!
        fail WowError, errors.full_messages unless valid?
        true
      end

      # Build an archive from this config
      # @param destination Destination folder of the archive file
      # @param filename Name of the archive file, optional, by default is name-version.wow
      # @return archive path with filename
      def create_archive(destination, filename = nil)
        validate!
        filename ||= "#{@name}-#{@version}.wow"
        path = File.join(destination, filename)
        Archive.write path do |archive|
          archive.add_files files
        end
        path
      end

      # Copy files to the installation folder
      # To install a program directly from the source(not an archive)
      # @param destination [String] folder where to install files
      def install_to(destination)
        files.each do |file|
          destination = File.join(Wow::Config.install_folder)
          FileUtils.cp(file, destination)
        end
      end
    end
  end
end