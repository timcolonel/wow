require 'wow/source'

class Wow::SourceList
  include Enumerable

  attr_accessor :sources
  # Creates a new SourceList
  def initialize
    @sources = []
  end

  # Creates a new SourceList from an array of sources.
  def self.from(ary)
    list = new
    list.replace ary
    return list
  end

  def initialize_copy(other)
    @sources = @sources.dup
  end

  # Add a new source to the list
  # @param source [Wow::Source|String] Source to add. The right source type will be deduced if source is a String
  # @return [Wow::Source]
  def <<(source)
    src = case source
            when Wow::Source
              source
            else
              Wow::Source.for(source)
          end

    @sources << src
    src
  end

  # Replaces this SourceList with the sources in +other+
  # The sources are cleared then added back with #<<.
  def replace(other)
    clear

    other.each do |x|
      self << x
    end

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
    if other.kind_of? Gem::Source
      @sources.include? other
    else
      @sources.find { |x| x.source.to_s == other.to_s }
    end
  end

  # Remove given +source+ from list
  def delete(source)
    if source.kind_of? Gem::Source
      @sources.delete source
    else
      @sources.delete_if { |x| x.source.to_s == source.to_s }
    end
  end

  # Iterate though all the sources to get the specs
  # @throw [Wow::Error] If none of the sources contains the package with given name tuple.
  def fetch_spec(name_tuple)
    sources.each_with_index do |source, i|
      begin
        return source.fetch_spec(name_tuple)
      rescue Wow::Error => e
        raise e if i == sources.size
      end
    end
  end

  # Search for package in all the source and get the latest version matching the query
  def find_package(package_name, version_range = nil, prerelease: false, first_match: true)
    found = []
    sources.each do |source|
      found << source.find_package(package_name, version_range, prerelease: prerelease)
      break if first_match and found.any?
    end
    found.compact.max_by { |s| s.spec.version }
  end
end