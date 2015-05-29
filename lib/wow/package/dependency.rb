require 'wow'

class Wow::Package::Dependency
  # Name of the package
  attr_accessor :name

  # Version condition
  # @see Wow::Package::VersionRange
  attr_accessor :version_range

  def initialize(name, version_range = Wow::Package::VersionRange.any)
    @name = name
    if version_range.is_a?(Wow::Package::VersionRange)
      @version_range = version_range
    else
      @version_range = Wow::Package::VersionRange.parse(version_range)
    end
  end

  def satisfied_by?(package)
    @version_range.match? package.version
  end
end
