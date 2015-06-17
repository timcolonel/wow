require 'wow'

# Contains the attributes for Specification and SpecificationLock
module Wow::Package::SpecAttributes
  # Package name [String]
  attr_accessor :name

  # Package version [Wow::Package::Version]
  attr_reader :version

  # Package homepage [String]
  attr_accessor :homepage

  # Package list of authors [Array<String>]
  attr_reader :authors

  # Package list of tags [Array<String>]
  attr_reader :tags

  # Short description of the package
  attr_reader :summary

  # Long description of the package
  attr_reader :description

  # Dependencies
  attr_reader :dependencies

  # List of attributes defined in this module
  def _attrs
    [:name, :version, :homepage, :authors, :tags, :summary, :description, :dependencies]
  end

  # Copy the attribute from a hash
  # @param hash [Hash]
  def initialize_attributes(hash = {})
    _attrs.each do |attr|
      send("#{attr}=".to_sym, hash[attr])
    end
  end

  # Copy the attribute from another object including this module
  # @param other [Object]
  def copy_attributes(other)
    _attrs.each do |attr|
      send("#{attr}=".to_sym, other.send(attr))
    end
  end

  # Return a hash of the attributes
  # @return [Hash]
  def attributes_hash
    _attrs.inject({}) do |hash, attr|
      hash.merge(attr => send(attr))
    end
  end

  # def attr_as_json(value)
  #   return '' if value.nil?
  #   return value.to_hash if value.respond_to?(:to_hash)
  #   return value.to_a if value.is_a?(Set)
  #   return value if value.is_a?(Array)
  #   value.to_s
  # end

  # Set the version
  # @param value [Version|String|Hash]
  def version=(value)
    @version =  Wow::Package::Version.from_json(value)
  end

  # Set the package summary.
  # @param content [String]
  def summary=(content)
    @summary = content || ''
  end

  # Set the description of the package.
  # @param content [String] Can either be the description itself or a filename.
  def description=(content)
    if content.nil?
      @description = ''
    elsif File.file?(content)
      @description = IO.read(content)
    else
      @description = content
    end
  end

  # Set the tags
  # @param ary [Array] array of tag
  def tags=(ary)
    ary ||= []
    @tags = ary
  end

  # Set the authors
  # @param ary [Array] array of author
  def authors=(ary)
    ary ||= []
    @authors = ary
  end

  # Set the dependencies
  # It can be set in the following ways:
  # * with an array of Wow::Package::Dependency
  # * with a Hash with key: package, value: version
  #   e.g. `{'package1' => '>= 1.1', 'package2' => '~> 1.1'}`
  # * with a Array of Array
  #   e.g. `[['package1', '>= 1.1'], ['package2', '~> 1.1']]`
  # @param array [Array|Hash]
  def dependencies=(array)
    if array.nil?
      @dependencies = Wow::Package::DependencySet.new
    elsif array.is_a? Wow::Package::DependencySet
      @dependencies = array
    else
      @dependencies = Wow::Package::DependencySet.new(array)
    end
  end
end
