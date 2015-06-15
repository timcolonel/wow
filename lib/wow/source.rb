# Template class for a source
class Wow::Source
  # Url/path/file
  attr_accessor :source

  # Get the source depending on what +source+ is.
  # * If source is a file then use SpecificFile
  # * If source is a folder then use Local
  # * If source is a url then use Remote
  # * Otherwise unsupported
  def self.for(source)
    if File.file?(source)
      Wow::Source::SpecificFile.new(source)
    elsif File.exist?(source)
      Wow::Source::Local.new(source)
    elsif source =~ URI.regexp
      Wow::Source::Remote.new(source)
    else
      fail ArgumentError, "Unknown source type #{source}"
    end
  end

  def initialize(source)
    @source = source
  end

  # List all the packages matching the query
  def list_packages(_package_name, _version_range = nil, prerelease: false)
    fail NotImplementedError
  end

  # Find the best package matching the query
  # By default it will use #list_packages and iterate through it.
  def find_package(package_name, version_range = nil, prerelease: false)
    packages = list_packages(package_name, version_range, prerelease: prerelease)
    packages.max_by { |pkg| pkg.spec.version }
  end

  def ==(other)
    return false unless other.is_a? Wow::Source
    @source == other.source
  end

  alias_method :eql?, :==
end

require 'wow/source/local'
require 'wow/source/remote'
require 'wow/source/specific_file'
