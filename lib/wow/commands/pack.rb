require 'wow/package/specification'

class Wow::Command::Pack
  def initialize(platform = :any, architecture=nil)
    @platform = platform
    @architecture = architecture
  end

  def run
    config = Wow::Package::Specification.load_valid!
    archive_path = config.create_archive(@platform, @architecture, destination: Dir.pwd)
    puts "Created archive in #{archive_path}"
  end
end