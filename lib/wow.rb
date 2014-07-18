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

    actions = {
        install: :install,
        instal: :install,
        build: :build
    }


    def initialize(options)
      @options = options
    end

    def run
      Wow::Builder.build(Dir.pwd, options['<platform>'])
    end

    #Extract the given filename to the installation folder
    def extract(filename)
      extractor = Wow::Extractor.new(filename)
      extractor.extract
    end

    def build

    end

    def install
    end

    def uninstall
    end

    def update

    end

    def updgrade

    end
  end
end
