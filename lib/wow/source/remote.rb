require 'wow/source'
require 'wow/package/version_range'

##
# Source for a directory containing .wow package.
class Wow::Source::Remote < Wow::Source
  attr_accessor :uri

  def initialize(uri)
    begin
      unless uri.is_a? URI
        uri = URI.parse(uri.to_s)
      end
    rescue URI::InvalidURIError
      raise if Gem::Source == self.class
    end
    @uri = uri
  end

  # @see Wow::Source#load_spec
  def load_specs(*args) # :nodoc:
  end

  # @see Wow::Source#fetch_spec
  def fetch_spec(name) # :nodoc:
  end

  # @see Wow::Source#download
  def download(spec, dir = nil)
  end

  def <=>(other)
  end
end
