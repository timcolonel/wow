require 'wow'

#
class Wow::Package::DependencySet
  include Enumerable
  attr_accessor :dependencies

  def initialize(dependencies = [])
    @dependencies = {}
    replace(dependencies)
  end

  # Insert a new dependency in the list
  # @param [Wow::Package::Dependency]
  def <<(dependency)
    if @dependencies.key? dependency.name
      @dependencies[dependency.name].merge!(dependency)
    else
      @dependencies[dependency.name] = dependency
    end
  end

  # Add another dependency list
  # @param other [Wow::Package::DependencySet]
  def +(other)
    other.each do |dep|
      add dep
    end
    self
  end

  alias_method :insert, :<<
  alias_method :add, :<<

  def each(&block)
    dependencies.values.each(&block)
  end

  # Replace with another dependency
  def replace(dependencies)
    @dependencies.clear
    dependencies = dependencies.to_a if dependencies.is_a? Hash
    dependencies.each do |dep|
      if dep.is_a?(Wow::Package::Dependency)
        insert dep
      else
        insert Wow::Package::Dependency.new(dep[0], dep[1])
      end
    end
  end

  def size
    @dependencies.size
  end

  def ==(other)
    dependencies == other.dependencies
  end

  def to_a
    dependencies.values
  end

  def to_hash
    to_a.map(&:to_hash)
  end

  alias_method :length, :size
end
