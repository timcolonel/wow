require 'wow/package/name_tuple'
require 'wow/package/target'
require 'toml'

# Specification lock.
class Wow::Package::SpecificationLock
  include Wow::Package::SpecAttributes

  attr_accessor :files, :executables, :target

  def initialize(platform, architecture = nil)
    replace_attributes
    @target = if platform.nil? || !platform.is_a?(Wow::Package::Target)
                Wow::Package::Target.new(platform, architecture)
              else
                platform
              end
    @files = []
    @executables = []
  end

  # @param [Wow::Package::Specification]
  def insert_specification(specification)
    merge_attributes(specification)
    @files << filename
    @files += specification.files.values
    @executables += specification.executables
  end

  def as_json
    out = {}
    to_hash.each { |k, v| out[k] = v.as_json }
    out
  end

  def to_hash
    attributes_hash.merge(target: @target,
                          files: @files,
                          executables: @executables)
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
      f.write(as_json.to_json)
    end
  end

  # Load the specification lock from a file.
  # @param filename [String]
  def self.load(filename)
    load_json(File.read(filename))
  end

  # Parse the given json content
  # @param json [String]
  def self.load_json(json)
    from_json(JSON.parse(json, symbolize_names: true))
  end

  # Extract from "JSON" structure(Hash, Array, String)
  def self.from_json(hash)
    spec_lock = new(Wow::Package::Target.from_hash(hash[:target]))
    spec_lock.replace_attributes(hash)
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
