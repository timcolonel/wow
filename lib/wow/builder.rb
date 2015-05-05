module Wow
  class Builder
    def initialize(directory, config_filename = 'wow.json', platform = :any)
      config = Wow::Package::Config.new(platform)
      config.load(config_filename)
      archive_path = config.create_archive(directory)
      puts "Created archive in #{archive_path}"
    end
  end
end