module Wow
  class Builder
    def initialize(directory, filename = 'wow.json',platform = :any)
      config = Wow::Package::Config.new(platform)
      archive_path = config.create_archive
    end
  end
end