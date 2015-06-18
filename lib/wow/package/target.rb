require 'yaml'

# A target is a combination of the following
# * platform: Target os (windows, linux, any, unix, osx, etc)
# * architecture: Target processor architecture any, x86, x64
class Wow::Package::Target
  attr_accessor :platform
  attr_accessor :architecture

  def initialize(platform = nil, architecture = nil)
    platform ||= :any
    architecture ||= :any
    @platform = platform
    @architecture = architecture
  end

  # platform.is?(other) => Boolean
  # Return true is the given platform is a parent or equals to this
  # i.e Self is a subset of the given platform.
  # @param platform [Wow::Package::Target] Other platform object to test
  # @return [Boolean]
  # e.g.
  #   win32.is?(windows)    => true
  #   windows.is?(win32)    => false
  #   windows.is?(windows)  => true
  def is?(platform)
    return false unless platform.is_a? Wow::Package::Target
    Wow::Package::Target.based_on?(platform, self)
  end

  # This this the opposite of is?. Return true if the given platform is a child or equals to this.
  # i.e The given platform is a subset of self
  # @param platform Other platform object to test
  #
  # e.g.
  #   windows.include?(win32)   => true
  #   win32.include?(windows)   => false
  #   windows.include?(windows) => true
  #
  def include?(platform)
    fail ArgumentError unless platform.is_a? Wow::Package::Target
    Wow::Package::Target.based_on?(self, platform)
  end

  def to_s
    str = @platform.to_s
    str << "-#{@architecture}" if @architecture != :any
    str
  end

  def as_json
    {platform: @platform.to_s, architecture: @architecture.to_s}
  end

  def to_hash
    {platform: @platform.to_s, architecture: @architecture.to_s}
  end

  def ==(other)
    if other.is_a? Symbol
      @architecture == :any && @platform == other
    elsif other.is_a? Wow::Package::Target
      to_a == other.to_a
    else
      false
    end
  end

  def to_a
    [@platform, @architecture]
  end

  def hash
    to_a.hash
  end

  def <=>(other)
    to_a <=> other.to_a
  end

  class << self
    def load
      hash = YAML.load_file(Wow::Config.asset_path('targets.yml'))
      @platforms = Tree.new(hash['platforms']).deep_symbolize
      @architectures = Tree.new(hash['architectures']).deep_symbolize
    end

    def platforms
      load if @platforms.nil?
      @platforms
    end

    def architectures
      load if @architectures.nil?
      @architectures
    end

    # Test to see if the child is based on the parent in the platform hierarchy
    # @param parent [Symbol|Wow::Package::Target] Parent to test against
    # @param child [Symbol|Wow::Package::Target] Child to test against
    # If parent or child are symbol the architecture will be default to `:any`
    # @return [Boolean]
    #
    # ```
    # Wow::Package::Platform.based_on? :all, :windows #=> true
    # Wow::Package::Platform.based_on? :unix, :osx #=> true
    # Wow::Package::Platform.based_on? Platform.new(:unix), Platform.new(:osx, :x64) #=> true
    # Wow::Package::Platform.based_on? Platform.new(:unix, :x64), Platform.new(:osx, :x64) #=> true
    # Wow::Package::Platform.based_on? Platform.new(:unix, :x64), Platform.new(:osx, :x32) #=> false
    # ```
    #
    def based_on?(parent, child)
      parent = Wow::Package::Target.new(parent) if parent.is_a? Symbol
      child = Wow::Package::Target.new(child) if child.is_a? Symbol
      platform_based_on?(parent, child) && architecture_base_on?(parent, child)
    end

    def platform_based_on?(parent, child)
      parent = parent.platform if parent.is_a? Wow::Package::Target
      child = child.platform if child.is_a? Wow::Package::Target

      parent_tree = Wow::Package::Target.platforms.find(parent)
      return false if parent_tree.nil?
      child_tree = parent_tree.find(child)
      !child_tree.nil?
    end

    def architecture_base_on?(parent, child)
      parent = parent.architecture if parent.is_a? Wow::Package::Target
      child = child.architecture if child.is_a? Wow::Package::Target

      parent_tree = Wow::Package::Target.architectures.find(parent)
      return false if parent_tree.nil?
      child_tree = parent_tree.find(child)
      !child_tree.nil?
    end

    def from_hash(hash)
      Wow::Package::Target.new(hash[:platform].to_sym, hash[:architecture].to_sym)
    end
  end
end
