require 'wow/source'
require 'wow/package/version_range'

##
# Source for a directory containing .wow package.
class Wow::Source::Remote < Wow::Source
  attr_accessor :uri

  def initialize(uri)
    @uri = URI.parse(uri.to_s)
  rescue URI::InvalidURIError
    raise Wow::Error("Invalid remote #{uri}")
  end
end
