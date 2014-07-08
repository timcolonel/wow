require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require_relative 'wow/archive'
require_relative 'wow/config'
require_relative 'wow/package/platform'
require_relative 'wow/package/config'
require_relative 'core_ext'
require_relative 'struct/tree'
require_relative 'wow/exception'


module Wow
  class << self
    #To be called with docopt arguments
    def run(options)
      puts options
      if options['build']
        Wow::Builder.build(Dir.pwd, options['<platform>'])
      end
    end

    #Extract the given filename to the installation folder
    def extract(filename)
      extractor = Wow::Extractor.new(filename)
      extractor.extract
    end
  end
end
