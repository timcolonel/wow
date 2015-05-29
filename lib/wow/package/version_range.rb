require 'wow/package/version'

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

  def merge!(other)
    if other.lower_bound > self.lower_bound
      self.lower_bound=other.lower_bound
    end

    if other.upper_bound
      if self.upper_bound.nil? or other.upper_bound < self.upper_bound
        self.upper_bound == other.upper_bound
      end
    end
    self
  end

  def merge(other)
    self.clone.merge!(other)
  end

  # Test if the given version match the range
  def match?(version)
    return false if version < lower_bound
    return true if upper_bound.nil?
    version <= upper_bound
  end

  alias_method :include?, :match?

  def self.any
    Wow::Package::VersionRange.new(lower_bound: Wow::Package::Version.new(major: 0, minor: 0, patch: 0, stage: :alpha))
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
end
