require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'require_all'
require 'wow/archive'
require 'wow/config'
require 'wow/package'
require 'wow/package/platform'
require 'wow/package/specification'
require 'core_ext'
require 'struct/tree'
require 'wow/exception'
require 'wow/command'
require 'wow/source_list'

module Wow
  class << self

    # Run with doctopt options
    def run(options)
      runner = Wow::Command.new(options)
      runner.run
    end

    def sources
      @sources ||= Wow::SourceList.new
    end
  end
end
