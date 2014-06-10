require 'active_support'
require 'active_support/core_ext'
require_relative 'wow/archive'
require_relative 'wow/config'
require_relative 'wow/package/platform'
require_relative 'wow/package/config'
require_relative 'core_ext'
require_relative 'struct/tree'
require_relative 'wow/exception'

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