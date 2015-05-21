require 'wow/source'
require 'wow/package/version_range'

##
# Source for a directory containing .wow package.
class Wow::Source::SpecificFile < Wow::Source
  attr_accessor :path

  def initialize(path)
    super(path)
    @path = path
    @package = Wow::Package.new(@path)
  end

  # @see Wow::Source#load_spec
  def load_specs(*args) # :nodoc:
    [@package.spec.name_tuple]
  end

  # @see Wow::Source#fetch_spec
  def fetch_spec(name) # :nodoc:
    return @package.spec if name == @package.spec.name_tuple
    raise Gem::Exception, "Unable to find '#{name}'"
  end

  # @see Wow::Source#download
  def download(spec, dir = nil)
    return @path if spec == @package.spec
    raise Gem::Exception, "Unable to download '#{spec.full_name}'"
  end

  ##
  # Orders this source against +other+.
  #
  # If +other+ is a SpecificFile from a different gem name +nil+ is returned.
  #
  # If +other+ is a SpecificFile from the same gem name the versions are
  # compared using Gem::Version#<=>
  #
  # Otherwise Gem::Source#<=> is used.
  def <=>(other)
    case other
      when Gem::Source::SpecificFile then
        return nil if @package.spec.name != other.package.spec.name

        @package.spec.version <=> other.package.spec.version
      else
        super
    end
  end
end