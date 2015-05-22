require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'require_all'
require 'wow/defaults'
require 'core_ext'

require 'wow/archive'
require 'wow/config'
require 'wow/package'
require 'wow/package/platform'
require 'wow/package/specification'
require 'struct/tree'
require 'wow/exception'
require 'wow/command'
require 'wow/source_list'

# Wow Module contains all the wow classes and modules
module Wow
  class << self
    # Run with docopt options
    def run(options)
      runner = Wow::Command.new(options)
      runner.run
    end

    def sources
      @sources ||= Wow.default_sources
    end

    def installed_sources
      @installed_sources ||= Wow.default_installed_source
    end
  end
end
