module Wow
  class Builder
    def initialize(filename,platform = :any)
      config = Wow::Package::Config.new(platform)
      Archive.all_files
    end
  end
end