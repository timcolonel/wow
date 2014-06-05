require 'active_support'

require_relative 'wow/archive'
require_relative 'wow/config'
require_relative 'wow/package/config'

Wow::Config::ROOT_FOLDER = File.expand_path('..', __FILE__) 
Wow::Config::DATA_FOLDER = "#{Wow::Config::ROOT_FOLDER}/assets"

puts 'Folder: '
puts Wow::Config::ROOT_FOLDER
puts Wow::Config::DATA_FOLDER
module Wow
  class << self
    def run(options)
      puts options
      if options['build']
        build options['<platform>']
      end
    end

    #Extract the given filename to the installation folder
    def extract(filename)
      extractor = Wow::Extractor.new(filename)
      extractor.extract
    end

    def build(platform = :any)
      Wow::Archive.create('test/test.txt', 'output.tar.gz')
    end

  end
end