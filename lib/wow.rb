require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require_relative 'wow/archive'
require_relative 'wow/config'
require_relative 'wow/builder'
require_relative 'wow/package/platform'
require_relative 'wow/package/config'
require_relative 'core_ext'
require_relative 'struct/tree'
require_relative 'wow/exception'
require_relative 'wow/runner'


module Wow
  class << self

    # Run with doctopt options
    def run(options)
      runner = Wow::Runner.new(options)
      runner.run
    end
  end
end
