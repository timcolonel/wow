class Command::Pack
  def initialize(platform = :any)
    @platform = platform
  end

  def run
    config = Wow::Package::Config.new(platform)
    config.init_from_toml(Wow::Package::Config.filename)
    archive_path = config.create_archive(directory)
    puts "Created archive in #{archive_path}"
  end
end