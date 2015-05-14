require 'wow/package/specification'

class Wow::Command::Pack
  def initialize(platform = :any)
    @platform = platform
  end

  def run
    config = Wow::Package::Specification.load_valid!(@platform)
    archive_path = config.create_archive(Dir.pwd)
    puts "Created archive in #{archive_path}"
  end
end