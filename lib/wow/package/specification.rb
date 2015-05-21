require 'toml'
require 'wow/package/file_pattern'
require 'wow/package/specification_lock'

class Wow::Package::Specification
  include ActiveModel::Validations

  # User config
  attr_accessor :name
  attr_reader :version
  attr_accessor :homepage
  attr_accessor :authors
  attr_accessor :short_description
  attr_accessor :description
  attr_accessor :executables
  attr_accessor :tags
  attr_accessor :files_included
  attr_accessor :files_excluded

  # Internal Config
  attr_accessor :platforms
  attr_accessor :platform_configs

  validates_presence_of :name, :version
  validates_format_of :name, :with => /\A[a-z0-9_-]+\z/,
                      :message => 'Error in config file. Name should only contain lowercase, numbers and _-'

  validate do
    @files_included.each do |pattern|
      errors.add :file_patterns,
                 "Path `#{pattern.pattern}`should be relative to the root but is an absolute path!" if Pathname.new(pattern.pattern).absolute?
    end
  end

  def self.filename
    return 'wow.toml'
  end

  # Will load the config from the current working directory
  # @return loaded config
  def self.load
    config = Wow::Package::Specification.new
    config.init_from_toml(Wow::Package::Specification.filename)
    config
  end

  # Will load the config from the current working directory and check it's valid
  # @return loaded config
  # @throw Wow::Error if the config is invalid @see Wow::Specification.validate!
  def self.load_valid!
    config = Wow::Package::Specification.new
    config.init_from_toml(Wow::Package::Specification.filename)
    config.validate!
    config
  end

  def initialize
    @files_included = []
    @files_excluded = []
    @tags = []
    @authors = []
    @executables = []

    @platforms = Set.new
    @platform_configs = {}
    @description = ''
    @short_description = ''
  end

  def file(files)
    @files_included += [*files].map { |x| Wow::Package::FilePattern.new(x) }
  end

  def exclude(files)
    @files_excluded += [*files].map { |x| Wow::Package::FilePattern.new(x) }
  end

  def executable(executables)
    @executables += executables
  end

  def platform(name, &block)
    platform_configs << {plaform: Wow::Package::Platform.new(name), block: block}
  end

  def version=(version)
    @version = if version.is_a? String
                 Wow::Package::Version.parse(version)
               else
                 version
               end
  end

  def +(config)
    fail ArgumentError unless config.is_a? Wow::Package::Specification
    self.files += config.files
    self.executables += config.executables
    self
  end

  def init_from_rb_file(file)
    File.open file, 'r' do |f|
      init_from_rb f.read
    end
  end

  def init_from_rb(ruby_str)
    self.instance_eval(ruby_str)
  end

  def init_from_toml(file)
    @files_included << Wow::Package::FilePattern.new(file)
    hash = TOML.load_file(file).deep_symbolize_keys
    init_from_hash(hash)
  end

  def init_from_hash(hash)
    @name = hash[:name]
    @version = Wow::Package::Version.parse(hash[:version]) if hash[:version]
    @homepage = hash[:homepage]
    @authors = hash.fetch(:authors, [])
    @tags = hash.fetch(:tags, [])
    @short_description = hash[:description]
    self.description = hash[:short_description]
    @files_included += hash.fetch(:files, []).map { |x| Wow::Package::FilePattern.new(x) }
    @files_excluded += hash.fetch(:files_excluded, []).map { |x| Wow::Package::FilePattern.new(x) }
    @executables += hash.fetch(:executables, [])
    if hash[:platform]
      exclude_arch = []
      hash[:platform].each do |platform_name, data|
        data.each do |arch_name, content|
          if Wow::Package::Platform.architectures.exist?(arch_name)
            platform = Wow::Package::Platform.new(platform_name, arch_name)
            @platforms << platform
            exclude_arch << arch_name
            platform_config = Wow::Package::Specification.new
            platform_config.init_from_hash(content)
            @platform_configs[platform] = platform_config
          end
        end
        next if exclude_arch.size == data.size

        platform = Wow::Package::Platform.new(platform_name)
        platform_config = Wow::Package::Specification.new
        platform_config.init_from_hash(data.except(exclude_arch))
        @platforms << platform
        @platform_configs[platform] = platform_config
      end
    end
  end

  def list_files_matching_patterns(file_patterns = [])
    patterns = [*file_patterns]
    results = {}
    patterns.each do |file_pattern|
      results.merge! file_pattern.file_map
    end
    results
  end

  # @return all files matching the pattern given in the files
  def files
    included_files = list_files_matching_patterns(@files_included)
    excluded_files = list_files_matching_patterns(@files_excluded)
    included_files.except(excluded_files.keys)
  end

  # Set the description of the package.
  # @param content: Can either be the description itself or a filename.
  def description=(content)
    return if content.nil?
    if File.exists?(content)
      @description = IO.read(content)
    else
      @description = content
    end
  end

  def target=(platform, architecture=:any)
    if platform.is_a? Symbol
      @target = Wow::Package::Platform.new(platform, architecture)
    else
      @target = platform
    end
  end

  # @return [Boolean]
  # * true if this config has a platform specified
  # * false if this config contains multiple platform(Just loaded from file)
  def platform_specific?
    not @target.platform == :any
  end

  # Return the platform specific config
  # i.e Flatten the platform specific Specs
  # @return [Wow::Package::Config]
  def get_platform_config(platform, architecture=:any)
    config = self.clone
    config.target = Wow::Package::Platform.new(platform, architecture)
    @platform_configs.each do |target, specification|
      if config.target.is? target
        config.merge_with(specification)
      end
    end
    config
  end

  def lock(platform, architecture=nil)
    spec_lock = Wow::Package::SpecificationLock.new(platform, architecture)
    spec_lock.insert_specification(self)
    @platform_configs.each do |target, specification|
      if spec_lock.target.is? target
        spec_lock.insert_specification(specification)
      end
    end
    spec_lock
  end

  def merge_with(specification)
    @files_included += specification.files_included
    @files_excluded += specification.files_excluded
    @executables += specification.executables
    @tags += specification.tags
  end

  # Raise am error if the config is invalid
  # @return [Boolean] true if succeed and raise WowError if not
  def validate!
    fail Wow::Error, errors.full_messages unless valid?
    true
  end

  # Build an archive from this config
  # @param destination Destination folder of the archive file
  # @return archive path with filename
  def create_archive(platform, architecture=nil, destination: nil)
    validate!
    spec_lock = self.lock(platform, architecture)
    spec_lock.save
    destination ||= Dir.pwd
    path = File.join(destination, archive_name)
    Wow::Archive.write path do |archive|
      archive.add_file spec_lock.filename
      archive.add_files files
    end
    path
  end

  # Equivalent to creating the archive then installing the archive to the given destination
  # To install a program directly from the source(not an archive)
  # @param destination [String] folder where to install files
  def install_to(platform, architecture=nil, destination: nil)
    destination ||= File.join(Wow::Config.package_install_root, package_folder)
    spec_lock = self.lock(platform, architecture)
    spec_lock.save
    files.merge({spec_lock.filename => spec_lock.filename}).each do |source, file_destination|
      output = File.join(destination, file_destination)
      FileUtils.mkdir_p(output)
      FileUtils.cp(source, output)
    end
  end

  # Return the name of the archive file
  # In the following format <name>-<version>[-<platform>[-<architecture>]].wow
  # See {Wow::Package::Specification#package_folder}
  def archive_name
    "#{package_folder}.wow"
  end

  # Return name of the folder. Used during installation and archive creation.
  # It follows this format <name>-<version>[-<platform>[-<architecture>]]
  # ```
  #   {name: 'example', version: '1.2.3'} # => example-1.2.3
  #   {name: 'example', version: '1.2.3', platform: 'unix'} # => example-1.2.3-unix
  #   {name: 'example', version: '1.2.3', platform: 'unix', arch: 'x86'} # => example-1.2.3-unix-x86
  # ```
  def package_folder
    @arch = nil
    array = [@name, @version]
    if @target and @target.platform != :any
      array << @target.platform
      if @target.architecture and @target.architecture != :any
        array << @target.architecture
      end
    end
    array.join('-')
  end
end