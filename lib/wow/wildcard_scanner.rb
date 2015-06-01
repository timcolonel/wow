require 'wow'

# Class to scan a wildcard in a pattern
class Wow::WildcardScanner

  attr_accessor :root
  attr_accessor :wildcard

  def initialize(pattern)
    @pattern = Pathname(pattern.to_s)
    @segments = @pattern.each_filename.to_a
    @root = @pattern.absolute? ? Pathname('/') : nil
    @wildcard = nil
    @found_wildcard = false
    scan
  end

  # Extract the root and wildcard part of the pattern
  def scan
    @segments.each_with_index do |segment, i|
      if @found_wildcard || segment.include?('*')
        add_to_wildcard(segment)
      else
        if i == @segments.size - 1 # For the last segment it might be a filename so we check
          add_to_wildcard(segment)
        else
          add_to_root(segment)
        end
      end
    end
  end

  protected

  def add_to_wildcard(segment)
    @wildcard = @wildcard.nil? ? Pathname.new(segment) : wildcard + segment
    @found_wildcard = true
  end

  def add_to_root(segment)
    @root = @root.nil? ? Pathname.new(segment) : root + segment
  end
end
