require 'wow/source'

# SourceList contains an ordered list of sources
# which provide method to find package in any of it's source
class Wow::SourceList
  include Enumerable

  attr_accessor :sources

  # Creates a new SourceList
  def initialize(sources = [])
    @sources = []
    sources.each do |source|
      self << source
    end
  end

  # Creates a new SourceList from an array of sources.
  def self.from(ary)
    new(ary)
  end

  def initialize_copy(other)
    @sources = other.dup
  end

  # Add a new source to the list
  # @param source [Wow::Source|String] Source to add.
  # The correct source type will be deduced if source is a String
  # @return [Wow::Source]
  def <<(source)
    source = Wow::Source.for(source) unless source.is_a? Wow::Source
    @sources << source
    source
  end

  # Replaces this SourceList with the sources in +other+
  # The sources are cleared then added back with #<<.
  def replace(other)
    other = Wow::SourceList.new(other) if other.is_a? Array
    @sources.replace(other.sources)
    self
  end

  # Removes all sources from the SourceList.
  def clear
    @sources.clear
  end

  # Yields each source in the list.
  def each(&b)
    @sources.each(&b)
  end

  # Returns true if there are no sources in this SourceList.
  def empty?
    @sources.empty?
  end

  def ==(other) # :nodoc:
    to_a == other
  end

  # Returns an Array of source URI Strings.
  def to_a
    @sources.map { |x| x.source.to_s }
  end

  alias_method :to_ary, :to_a

  # Deletes +source+ from the source list which may be a Wow::Source or a URI.
  # Returns true if this source list includes +other+ which may be a
  # Wow::Source or a source URI.
  def include?(other)
    if other.is_a? Wow::Source
      @sources.include? other
    else
      @sources.find { |x| x.source.to_s == other.to_s }
    end
  end

  # Remove given +source+ from list
  def delete(source)
    if source.is_a? Wow::Source
      @sources.delete source
    else
      @sources.delete_if { |x| x.source.to_s == source.to_s }
    end
  end

  # List all the package in the source list matching the condition
  # @param package_name [String] Name of the package to install
  # @param version_range [VersionRange] Version condition the package must match
  # @param prerelease [Boolean] Allow prerelease
  # @return [Array<Package>]
  def list_packages(package_name, version_range = nil, prerelease: false)
    found = []
    sources.each do |source|
      found += source.list_packages(package_name, version_range, prerelease: prerelease)
    end
    found
  end

  # Search for package in all the source and get the latest version matching the query
  # @param package_name [String] Name of the package to install
  # @param version_range [VersionRange] Version condition the package must match
  # @param prerelease [Boolean] Allow prerelease
  # @param first_match [Boolean] If true only the first package found will be return,
  #   if false the package with the highest version will be returned
  # @return [Package]
  def find_package(package_name, version_range = nil, prerelease: false, first_match: true)
    found = []
    sources.each do |source|
      found << source.find_package(package_name, version_range, prerelease: prerelease)
      break if first_match && found.any?
    end
    found.compact.max_by { |s| s.spec.version }
  end
end
