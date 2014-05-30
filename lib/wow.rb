module Wow
  class << self
    def run(options)
      puts options
    end

    #Extract the given filename to the installation folder
    def extract(filename)
      extractor = Wow::Extractor.new(filename)
      extractor.extract
    end
  end
end