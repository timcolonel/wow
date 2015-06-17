require 'wow/package/version'

# Version Range
class Wow::Package::VersionRange
  # Range lower bound
  attr_accessor :lower_bound

  # Range upper bound, nil for none
  attr_accessor :upper_bound

  # Include hash Default: {lower_bound: true, upper_bound: false}
  attr_accessor :include

  class << self
    attr_accessor :patterns

    def register_pattern(name, regex, &block)
      @patterns ||= []
      @patterns << [name, regex, block]
    end
  end

  register_pattern :more_equal, /\A>= (.*)\Z/x do |version|
    Wow::Package::VersionRange.new(lower_bound: version, include: {lower_bound: true})
  end

  register_pattern :more, /\A> (.*)\Z/x do |version|
    Wow::Package::VersionRange.new(lower_bound: version, include: {lower_bound: false})
  end

  register_pattern :less_equal, /\A<= (.*)\Z/x do |version|
    Wow::Package::VersionRange.new(upper_bound: version, include: {upper_bound: true})
  end

  register_pattern :less, /\A< (.*)\Z/x do |version|
    Wow::Package::VersionRange.new(upper_bound: version, include: {upper_bound: false})
  end

  register_pattern :tilt, /\A~> (.*)\Z/x do |version|
    Wow::Package::VersionRange.new(lower_bound: version, upper_bound: version.get_upper_bound)
  end

  # Need to be last as it's the more general value(The equal operator is optional)
  register_pattern :equal, /\A=? (.*)\Z/x do |version|
    Wow::Package::VersionRange.new(version)
  end

  # Create a new VersionRange
  # @param value [Version|String]
  # @param lower_bound [Version]
  # @param upper_bound [Version]
  # ```
  # version = Version.parse('1.2.3')
  # # The following are equivalents
  # VersionRange.new('1.2.3')
  # VersionRange.new(version)
  # VersionRange.new(lower_bound: version, upper_bound: version)
  #
  # # The upper bound can be omitted then any version over the lower bound will work
  # VersionRange.new(lower_bound: '1.2.3')
  # ```
  def initialize(value = nil, lower_bound: nil, upper_bound: nil, include: {})
    @include = default_include.merge(include)
    if value.nil?
      @lower_bound = lower_bound || Wow::Package::Version.zero
      @upper_bound = upper_bound
    elsif value.is_a? Wow::Package::Version
      @lower_bound = @upper_bound = value
    else
      @lower_bound = Wow::Package::Version.zero
      parse(value)
    end
  end

  def default_include
    {lower_bound: true, upper_bound: false}
  end

  def include_lower_bound?
    @include[:lower_bound]
  end

  def include_upper_bound?
    @include[:upper_bound]
  end

  def self.parse(str)
    new(str)
  end

  # Parse a version range
  # @param str [String]
  # @return [Wow::Package::VersionRange]
  def parse(str)
    parts = str.split(',')
    parts.each do |part|
      range = self.class.parse_part(part)
      merge!(range)
    end
  end

  def self.parse_part(part)
    @patterns.each do |_name, regex, block|
      next unless regex =~ part.squeeze(' ').strip
      value = Wow::Package::Version.parse(Regexp.last_match[1], true)
      return block.call(value)
    end
  end

  # Merge with another version range.
  # Modify method
  # @param other [Wow::Package::VersionRange]
  def merge!(other)
    if other.lower_bound > @lower_bound
      @lower_bound = other.lower_bound
      @include[:lower_bound] = other.include_lower_bound?
    end
    if other.upper_bound
      if @upper_bound.nil? || other.upper_bound < @upper_bound
        @upper_bound = other.upper_bound
        @include[:upper_bound] = other.include_upper_bound?
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
    return include_lower_bound? if version == lower_bound
    return true if upper_bound.nil?
    return false if version > upper_bound
    return include_upper_bound? if version == upper_bound
    true
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
    @upper_bound == other.upper_bound &&
      @lower_bound == other.lower_bound &&
      @include == other.include
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
