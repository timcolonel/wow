
# Template class for a source
class Wow::Source
  # Url/path/file
  attr_accessor :source

  def initialize(source)
    @source = source
  end

  # Load a list of specs in the source
  # @param filter [Symbol] filter the packages.
  #   Can have the following values: :release, :prerelease, :latest_release, :latest
  def list_packages(filter)
    fail NotImplementedError
  end

  # Load a list of specs in the source
  def find_package(package_name, version_range = Wow::Package::VersionRange.any, prerelease: false)
    fail NotImplementedError
  end

  def fetch_spec(name)
    fail NotImplementedError
  end

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
end

require 'wow/source/local'
require 'wow/source/remote'
require 'wow/source/specific_file'
