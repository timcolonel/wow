require_relative 'wow/archive'
module Wow
  class << self
    def run(options)
      puts options
      if options['build']
        build
      end
    end

    #Extract the given filename to the installation folder
    def extract(filename)
      extractor = Wow::Extractor.new(filename)
      extractor.extract
    end

    def build
      Wow::Archive.create('test/test.txt', 'output.tar.gz')
    end

  end
end