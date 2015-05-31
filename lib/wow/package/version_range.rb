require 'wow/package/version'

# Version Range
class Wow::Package::VersionRange
  attr_accessor :lower_bound
  attr_accessor :upper_bound


  EQUAL_REGEX = /\A=? (.*)\Z/x

  MORE_REGEX = /\A>= (.*)\Z/x

  TILT_REGEX = /\A~> (.*)\Z/x


  def initialize(lower_bound:, upper_bound: nil)
    @lower_bound = lower_bound
    @upper_bound = upper_bound
  end

  # Parse a version range
  # @param str [String]
  # @return [Wow::Package::VersionRange]
  def self.parse(str)
    parts = str.split(',')
    current_range = nil
    parts.each do |part|
      range = if part.match(MORE_REGEX)
                version = Wow::Package::Version.parse(part.scan(MORE_REGEX)[0][0], true)
                Wow::Package::VersionRange.new(lower_bound: version)
              elsif part.match(TILT_REGEX)
                version = Wow::Package::Version.parse(part.scan(TILT_REGEX)[0][0], true)
                Wow::Package::VersionRange.new(lower_bound: version, upper_bound: version.get_upper_bound)
              elsif part.match(EQUAL_REGEX)
                version = Wow::Package::Version.parse(part.scan(EQUAL_REGEX)[0][0], true)
                Wow::Package::VersionRange.new(lower_bound: version, upper_bound: version)
              else
                fail ArgumentError("Version range '#{part}' is invalid!")
              end
      current_range = current_range.nil? ? range : current_range.merge(range)
    end
    current_range
  end

  # Merge with another version range.
  # Modify method
  # @param other [Wow::Package::VersionRange]
  def merge!(other)
    self.lower_bound = other.lower_bound if other.lower_bound > @lower_bound

    if other.upper_bound
      if @upper_bound.nil? || other.upper_bound < @upper_bound
        @upper_bound = other.upper_bound
      end
    end
    self
  end


  def merge(other)
    clone.merge!(other)
  end

  # Test if the given version match the range
  def match?(version)
    return false if version < lower_bound
    return true if upper_bound.nil?
    version <= upper_bound
  end

  alias_method :include?, :match?

  # Return a new range that accept any of the range
  # @return [Wow::Package::VersionRange]
  def self.any
    version = Wow::Package::Version.new(major: 0, minor: 0, patch: 0, stage: :alpha)
    Wow::Package::VersionRange.new(lower_bound: version)
  end

  def ==(other)
    return false unless other.is_a? Wow::Package::VersionRange
    @upper_bound == other.upper_bound && @lower_bound == other.lower_bound
  end

  def to_s
    if upper_bound
      "#{lower_bound} - #{upper_bound}"
    else
      ">= #{lower_bound}"
    end
  end

  # Return if the range contains at least 1 version(lower_bound <= upper_bound)
  # @return [Boolean]
  def any?
    !empty?
  end

  # Return if the range cannot contain a version(lower_bound > upper_bound)
  # @return [Boolean]
  def empty?
    return false if @upper_bound.nil?
    @lower_bound > @upper_bound
  end
end
