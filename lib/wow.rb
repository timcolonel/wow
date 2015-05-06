require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'require_all'
require_relative 'wow/archive'
require_relative 'wow/config'
require_relative 'wow/package/platform'
require_relative 'wow/package/config'
require_relative 'core_ext'
require_relative 'struct/tree'
require_relative 'wow/exception'
require_relative 'wow/command'


module Wow
  class << self

    # Run with doctopt options
    def run(options)
      runner = Wow::Command.new(options)
      runner.run
    end
  end
end
