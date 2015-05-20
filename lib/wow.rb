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


module Wow
  class << self

    # Run with doctopt options
    def run(options)
      runner = Wow::Command.new(options)
      runner.run
    end
  end
end
