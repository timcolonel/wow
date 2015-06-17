require 'toml'
require 'wow/package/file_pattern'
require 'wow/package/specification_lock'

# Package Specification
# This class is the mapping of the user specification defined in the oml file
class Wow::Package::Specification
  include ActiveModel::Validations
  include Wow::Package::SpecAttributes

  # User config
  attr_accessor :executables
  attr_reader :files_included
  attr_reader :files_excluded

  # Internal Config
  attr_accessor :platform_configs

  validates_presence_of :name, :version
  validates_format_of :name,
                      with: /\A[a-z0-9_-]+\z/,
                      message: 'Error in config file. Should only contain lowercase, numbers and _-'

  validate do
    @files_included.each do |pattern|
      if Pathname.new(pattern.pattern).absolute?
        errors.add :file_patterns,
                   "Path `#{pattern.pattern}`should be relative to the root but is an absolute path!"
      end
    end
  end

  def self.filename
    'wow.toml'
  end

  # Will load the config from the current working directory
  # @return loaded config
  def self.load
    Wow::Package::Specification.from_toml(Wow::Package::Specification.filename)
  end

  # Will load the config from the current working directory and check it's valid
  # @return loaded config
  # @throw Wow::Error if the config is invalid @see Wow::Specification.validate!
  def self.load_valid!
    config = Wow::Package::Specification.from_toml(Wow::Package::Specification.filename)
    config.validate!
    config
  end

  def self.from_toml(file)
    hash = TOML.load_file(file).deep_symbolize_keys
    spec = Wow::Package::Specification.new(hash)
    spec.files_included << Wow::Package::FilePattern.new(file)
    spec
  end

  # Initialize a new specification
  def initialize(hash = {})
    initialize_attributes(hash)
    self.files_included = hash[:files]
    self.files_excluded = hash[:files_excluded]
    @executables = hash.fetch(:executables, [])
    @platform_configs = {}
    load_platforms(hash[:platform])
  end

  # Load the platform_name specific spec
  def load_platforms(platform_hash)
    return if platform_hash.nil?
    platform_hash.each do |platform_name, data|
      load_platform(platform_name, data)
    end
  end

  # Load the platform_name from the hash
  # Format can be
  # * platform_name.[Spec]
  # * platform_name.arch.[Spec]
  # @param platform_name [String] name of the platform_name
  # @param data [Hash] Platform specific specs.
  def load_platform(platform_name, data)
    exclude_arch = []
    # Check if arch specific specs are defined
    data.each do |arch_name, content|
      next unless Wow::Package::Target.architectures.exist?(arch_name)

      platform = Wow::Package::Target.new(platform_name, arch_name)
      exclude_arch << arch_name
      platform_config = Wow::Package::Specification.new(content)
      @platform_configs[platform] = platform_config
    end
    return if exclude_arch.size == data.size

    platform = Wow::Package::Target.new(platform_name)
    platform_config = Wow::Package::Specification.new(data.except(exclude_arch))
    @platform_configs[platform] = platform_config
  end

  # Add a new file to the specification
  # @param files [String|Array] File or list of files
  def file(files)
    @files_included += [*files].map { |x| Wow::Package::FilePattern.new(x) }
  end

  # Exclude a file from the specification
  # @param files [String|Array] File or list of files
  def exclude(files)
    @files_excluded += [*files].map { |x| Wow::Package::FilePattern.new(x) }
  end

  # Add a new executable
  # @param executables [String|Array] File or list of files
  def executable(executables)
    @executables += executables
  end

  def platform(name, &block)
    platform_configs << {plaform: Wow::Package::Target.new(name), block: block}
  end

  # Set the list of files included
  # @param files [Array] files
  def files_included=(files)
    files ||= []
    @files_included = files.map do |x|
      if x.is_a? Wow::Package::FilePattern
        x
      else
        Wow::Package::FilePattern.new(x)
      end
    end
  end

  # Set the list of files excluded
  # @param files [Array] files
  def files_excluded=(files)
    files ||= []
    @files_excluded = files.map do |x|
      if x.is_a? Wow::Package::FilePattern
        x
      else
        Wow::Package::FilePattern.new(x)
      end
    end
  end


  # List all the defined platforms
  # @return [Array<Wow::Package::Target>]
  def platforms
    @platform_configs.keys
  end

  def +(other)
    fail ArgumentError unless other.is_a? Wow::Package::Specification
    self.files += other.files
    self.executables += other.executables
    self
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

  # Return the platform_name specific config
  # i.e Flatten the platform_name specific Specs
  # @return [Wow::Package::Config]
  def get_platform_config(platform, architecture = :any)
    config = clone
    config.target = Wow::Package::Target.new(platform, architecture)
    @platform_configs.each do |target, specification|
      config.merge!(specification) if config.target.is? target
    end
    config
  end

  def lock(platform, architecture = nil)
    spec_lock = Wow::Package::SpecificationLock.new(platform, architecture)
    spec_lock.insert_specification(self)
    @platform_configs.each do |target, specification|
      if spec_lock.target.is? target
        spec_lock.insert_specification(specification)
      end
    end
    spec_lock
  end


  def merge!(other)
    @files_included += other.files_included
    @files_excluded += other.files_excluded
    @executables += other.executables
    @tags += other.tags
  end

  def merge(other)
    self.clone.merge!(other)
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
  def create_archive(platform, architecture = nil, destination: nil)
    validate!
    spec_lock = lock(platform, architecture)
    spec_lock.save
    destination ||= Dir.pwd
    path = File.join(destination, spec_lock.name_tuple.archive_filename)
    Wow::Archive.write path do |archive|
      archive.add_file spec_lock.filename
      archive.add_files files
    end
    path
  end

  # Equivalent to creating the archive then installing the archive to the given destination
  # To install a program directly from the source(not an archive)
  # @param destination [String] folder where to install files
  def install_to(platform, architecture = nil, destination: nil)
    destination ||= File.join(Wow::Config.package_install_root, package_folder)
    spec_lock = lock(platform, architecture)
    spec_lock.save
    files.merge(spec_lock.filename => spec_lock.filename).each do |source, file_destination|
      output = File.join(destination, file_destination)
      FileUtils.mkdir_p(output)
      FileUtils.cp(source, output)
    end
  end
end
