module Wow
  class Builder
    def initialize(directory, filename = 'wow.json',platform = :any)
      config = Wow::Package::Config.new(platform)
      archive_path = config.create_archive
      puts "Created archive in #{archive_path"
    end
  end
end