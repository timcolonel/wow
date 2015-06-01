require 'wow/package/name_tuple'
require 'wow/package/platform'
require 'toml'

# Specification lock.
class Wow::Package::SpecificationLock

  attr_accessor :target, :files, :executables, :dependencies,
                :name, :version, :authors, :tags, :homepage, :description, :short_description

  def initialize(platform, architecture = nil)
    @target = if platform.nil? || !platform.is_a?(Wow::Package::Platform)
                Wow::Package::Platform.new(platform, architecture)
              else
                platform
              end
    @files = Set.new
    @executables = Set.new
    @tags = Set.new
    @authors = Set.new
    @dependencies = Wow::Package::DependencySet.new
  end

  # @param [Wow::Package::Specification]
  def insert_specification(specification)
    @name ||= specification.name
    @version ||= specification.version
    @homepage ||= specification.homepage
    @description ||= specification.description
    @short_description ||= specification.short_description

    @tags += specification.tags
    @authors += specification.authors

    @files << filename
    @files += specification.files.values
    @executables += specification.executables
    @dependencies += specification.dependencies
  end

  def to_hash
    {name: @name.to_s,
     target: @target.to_hash,
     version: @version.to_s,
     authors: @authors.to_a,
     tags: @tags.to_a,
     homepage: @homepage.to_s,
     description: @description,
     short_description: @short_description,
     files: @files.to_a,
     executables: @executables.to_a,
     dependencies: @dependencies.to_hash}
  end

  def filename
    name_tuple.lock_filename
  end

  def self.filename_in_archive(archive_filename)
    tuple = Wow::Package::NameTuple.from_archive_name(archive_filename)
    spec_lock = Wow::Package::SpecificationLock.new(tuple.target)
    spec_lock.name = tuple.name
    spec_lock.filename
  end

  def save
    File.open filename, 'w' do |f|
      f.write(TOML.dump(to_hash))
    end
  end

  def self.load(filename)
    Wow::Package::SpecificationLock.load_toml(File.read(filename))
  end

  def self.load_toml(toml)
    Wow::Package::SpecificationLock.from_hash(TOML.parse(toml).deep_symbolize_keys)
  end

  def self.from_hash(hash)
    spec_lock = Wow::Package::SpecificationLock.new(Wow::Package::Platform.from_hash(hash[:target]))
    spec_lock.name = hash[:name]
    spec_lock.version = Wow::Package::Version.parse(hash[:version])
    spec_lock.authors = hash[:authors]
    spec_lock.tags = hash[:tags]
    spec_lock.homepage = hash[:homepage]
    spec_lock.description = hash[:description]
    spec_lock.short_description = hash[:short_description]
    spec_lock.files = hash[:files]
    spec_lock.executables = hash[:executables]
    spec_lock
  end

  def name_tuple
    Wow::Package::NameTuple.new(@name, @version, @target)
  end

  def ==(other)
    to_hash == other.to_hash
  end
end
