require 'wow'

# Package Dependency.
# Contain the name and version condition of a package
class Wow::Package::Dependency
  # Name of the package
  attr_accessor :name

  # Version condition
  # @see Wow::Package::VersionRange
  attr_accessor :version_range

  def initialize(name, version_range = Wow::Package::VersionRange.any)
    @name = name.to_s
    if version_range.is_a?(Wow::Package::VersionRange)
      @version_range = version_range
    else
      @version_range = Wow::Package::VersionRange.parse(version_range)
    end
  end

  def satisfied_by?(spec)
    @version_range.match? spec.version
  end

  def merge!(dependency)
    @version_range.merge!(dependency.version_range)
  end
end
