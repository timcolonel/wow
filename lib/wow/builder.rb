module Wow
  class Builder
    def initialize(filename,platform = :any)
      config = Wow::Package::Config.new(platform)
      archive_path = config.create_archive
      puts "Package created in #{archive_path}"
    end
  end
end