require 'toml'

class Wow::Package::Specification
  include ActiveModel::Validations

  # User config
  attr_accessor :name
  attr_accessor :version
  attr_accessor :homepage
  attr_accessor :authors
  attr_accessor :short_description
  attr_accessor :description
  attr_accessor :executables
  attr_accessor :files
  attr_accessor :files_exclude
  attr_accessor :tags

  # Internal Config
  attr_accessor :platform
  attr_accessor :file_patterns
  attr_accessor :platforms
  attr_accessor :platform_configs

  validates_presence_of :name, :version
  validates_format_of :name, :with => /\A[a-z0-9_-]+\z/,
                      :message => 'Error in config file. Name should only contain lowercase, numbers and _-'

  validate do
    @file_patterns.each do |pattern|
      errors.add :file_patterns,
                 "Path `#{pattern}`should be relative to the root but is an absolute path!" if Pathname.new(pattern).absolute?
    end
  end

  def self.filename
    return 'wow.toml'
  end

  # Will load the config from the current working directory
  # @return loaded config
  def self.load(platform=:any)
    config = Wow::Package::Specification.new(platform)
    config.init_from_toml(Wow::Package::Specification.filename)
    config
  end

  # Will load the config from the current working directory and check it's valid
  # @return loaded config
  # @throw Wow::Error if the config is invalid @see Wow::Specification.validate!
  def self.load_valid!(platform=:any)
    config = Wow::Package::Specification.new(platform)
    config.init_from_toml(Wow::Package::Specification.filename)
    config.validate!
    config
  end

  def initialize(platform = nil)
    @platform = Wow::Package::Platform.new(platform)
    @file_patterns = []
    @platforms = Set.new
    @platform_configs = {}
    @description = ''
    @short_description = ''
  end


  def file(files)
    @file_patterns += [*files]
  end

  def executable(executables)
    @executables += executables
  end

  def platform(name, &block)
    platform_configs << {plaform: Wow::Package::Platform.new(name), block: block}
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
    hash = TOML.load_file(file).deep_symbolize_keys
    init_from_hash(hash)
  end

  def init_from_hash(hash)
    @name = hash[:name]
    @version = hash[:version]
    @homepage = hash[:homepage]
    @authors = hash[:authors]
    @tags = hash[:tags]
    @short_description = hash[:description]
    self.description = hash[:short_description]
    @files = hash[:files]
    @files_excluded = hash[:files_excluded]
    @executables = hash[:executables]
    if hash[:platform]
      hash[:platform].each do |platform_name, data|
        platform = Wow::Package::Platform.new(platform_name)
        @platforms << platform
        platform_config = Wow::Package::Specification.new(@platform)
        platform_config.init_from_hash(data)
        @platform_configs[platform] = platform_config
      end
    end
  end

  # @return all files matching the pattern given in the files
  def files
    results = []
    @file_patterns.each do |file_pattern|
      if File.directory?(file_pattern)
        results += Dir.glob(File.join(file_pattern, '**/*'))
      else
        results += Dir.glob(file_pattern)
      end
    end
    results
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

  # @return [Boolean]
  # * true if this config has a platform specified
  # * false if this config contains multiple platform(Just loaded from file)
  def platform_specific?
    not platform.nil?
  end

  # Return the platform specific config
  # @return [Wow::Package::Config]
  def get_platform_config(platform)
    config = Wow::Package::Specification.new(platform)
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
    fail Wow::Error, errors.full_messages unless valid?
    true
  end

  # Build an archive from this config
  # @param destination Destination folder of the archive file
  # @param filename Name of the archive file, optional, by default is name-version.wow
  # @return archive path with filename
  def create_archive(destination, filename = nil)
    validate!
    filename ||= archive_name
    path = File.join(destination, filename)
    Wow::Archive.write path do |archive|
      archive.add_files files
    end
    path
  end

  # Copy files to the installation folder
  # To install a program directly from the source(not an archive)
  # @param destination [String] folder where to install files
  def install_to(destination)
    destination ||= File.join(Wow::Config.install_folder)
    files.each do |file|
      FileUtils.cp(file, destination)
    end
  end

  # Return the name of the archive file
  # In the following format <name>-<version>[-<platform>[-<architecture>]]
  # e.g.
  #   example-1.2.3.wow
  #   example-1.2.3-unix-x86
  def archive_name
    @arch = nil
    array = [@name, @version]
    if @platform and @platform.key != :any
      array << @platform
      if @arch and @arch != :any
        array << @arch
      end
    end


    "#{array.join('-')}.wow"
  end
end