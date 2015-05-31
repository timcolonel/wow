require 'prime'
require 'wow/package'

# Contains a package version.
class Wow::Package::Version
  include Comparable

  VERSION_REGEX = /
    \A
    (\d+)\.(\d+)(?:\.(\d+)    # x.y.z
    (?:(?:\.|\-)([a-z]+))?    # (-|.)stage
    (?:\.(\d+))?)?             # .identifier
    \Z
  /ix

  attr_reader :major, :minor, :patch, :stage, :identifier

  def initialize(major:, minor:, patch: nil, stage: :release, identifier: nil)
    self.major = major
    self.minor = minor
    self.patch = patch
    self.stage = stage
    self.identifier = identifier
  end

  def major=(major)
    @major = major.to_i
  end

  def minor=(minor)
    @minor = minor.to_i
  end

  def stage=(stage)
    fail ArgumentError("Unknown stage '#{stage}'") unless Wow::Package::Version.stages.has_key? stage.to_sym
    @stage = stage.to_sym
  end

  def patch=(patch)
    @patch = patch.nil? ? nil : patch.to_i
  end

  def identifier=(value)
    @identifier = value.nil? ? nil : value.to_i
  end

  def self.stages
    {alpha: 0, beta: 1, release_candidate: 2, release: 3}
  end

  def self.stage_initial
    {alpha: 'a', beta: 'b', release_candidate: 'rc', release: 'r'}
  end

  def self.coefficient_multiplier
    {major: 1000, minor: 1000, patch: 1000, stage: 10, identifier: 100000}
  end

  def self.coefficient
    result = {identifier: coefficient_multiplier[:identifier]}
    result[:stage]=coefficient_multiplier[:stage]*result[:identifier]
    result[:patch]=coefficient_multiplier[:patch]*result[:stage]
    result[:minor]=coefficient_multiplier[:minor]*result[:patch]
    result[:major]=coefficient_multiplier[:major]*result[:minor]
    result
  end


  # Parse a version string.
  # @param str [String] version in the string format to parse
  # @param allow_incomplete [Boolean] If true the version must have a valid format if false. Only the major and minor can be provided(Used for dependency matching)
  # @return [Wow::Package::Version]
  def self.parse(str, allow_incomplete=false)
    result = str.strip.scan(Wow::Package::Version::VERSION_REGEX)
    if result.empty? or (not allow_incomplete and result[0][2].nil?)
      fail ArgumentError.new("Version string '#{str}' is in the wrong format check the documentation!")
    end
    matches = result[0]
    stage = if matches[3].nil?
              :release
            elsif Wow::Package::Version.stages.has_key? matches[3].to_sym
              matches[3]
            elsif Wow::Package::Version.stage_initial.has_value? matches[3]
              Wow::Package::Version.stage_initial.key(matches[3])
            else
              :release
            end
    Wow::Package::Version.new(major: matches[0],
                              minor: matches[1],
                              patch: matches[2],
                              stage: stage,
                              identifier: matches[4])

  end

  # Return the version to string
  # @param short [Boolean] If true the stage will use the initial instead of the full name(e.g. b for beta)
  # @param hide_release [Boolean] If true the stage will not be included if it is release
  # ```
  #   Version.new(major: 1, minor: 2, patch: 3).to_s # => '1.2.3'
  #   Version.new(major: 1, minor: 2, patch: 3, stage: :beta).to_s # => '1.2.3-b'
  #   Version.new(major: 1, minor: 2, patch: 3, identifier: 798).to_s # => '1.2.3.798'
  #   Version.new(major: 1, minor: 2, patch: 3, stage: :beta).to_s(short: false) # => '1.2.3-beta'
  #   Version.new(major: 1, minor: 2, patch: 3).to_s(include_release: true) # => '1.2.3-r'
  #   Version.new(major: 1, minor: 2, patch: 3).to_s(short: false, include_release: true) # => '1.2.3-release'
  # ```
  def to_s(short: true, hide_release: true)
    str = [major, minor, patch].join('.')
    unless hide_release && stage.to_sym == :release
      str << ".#{short ? Wow::Package::Version.stage_initial[stage.to_sym] : stage}"
    end
    str << ".#{identifier}" unless identifier.nil?
    str
  end


  # Build a unique number from the version.
  # The number follows the version comparison
  # i.e (version1 <=> version2) == (version1.unique <=> version2.unique)
  # The output number will have the following format
  # AAA_BBB_CCC_D_EEEEE
  # AAA: major (0..999)
  # BBB: minor (0..999)
  # CCC: patch (0..999)
  # D: stage (0..9)
  # EEEEE: identifier (0..99_999)
  def unique
    id = 0
    id += unique_value(:identifier, @identifier)
    id += unique_value(:stage, Wow::Package::Version.stages[@stage])
    id += unique_value(:patch, @patch)
    id += unique_value(:minor, @minor)
    id + unique_value(:major, @major)
  end

  def <=>(other)
    unique <=> other.unique
  end

  def get_upper_bound
    upper_bound = clone
    if @patch.nil?
      upper_bound.major = @major + 1
      upper_bound.minor = 0
      upper_bound.patch = 0
    else
      upper_bound.minor = @minor + 1
      upper_bound.patch = 0
    end
    upper_bound
  end

  def prerelease?
    stage != :release
  end

  def to_a
    [@major, @minor, @patch, @stage, @identifier]
  end

  def hash
    to_a.hash
  end

  private def unique_value(attribute, value)
    return 0 if value.nil?
    multiplier = Wow::Package::Version.coefficient_multiplier[attribute]
    coefficient = Wow::Package::Version.coefficient[attribute]
    fail ArgumentError, "Value #{value} cannot be negative" if value < 0
    if value >= multiplier
      fail ArgumentError, "Value #{value} for #{attribute} need to be less than #{multiplier}." \
                          'Do you REALLY need a number that big in your version!'
    end
    value * coefficient
  end
end
