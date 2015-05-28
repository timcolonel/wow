require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'require_all'
require 'wow/defaults'
require 'core_ext'
require 'clin'
require 'wow/archive'
require 'wow/config'
require 'wow/package'
require 'wow/package/platform'
require 'wow/package/specification'
require 'struct/tree'
require 'wow/exception'
require 'wow/source_list'
# Wow Module contains all the wow classes and modules
module Wow
  class << self
    attr_writer :remote

    def sources
      @sources ||= Wow.default_sources
    end

    def installed_sources
      @installed_sources ||= Wow.default_installed_source
    end

    def exe
      'wow'
    end

    def remote
      @remote ||= Wow.default_remote
    end
  end
end

require_rel 'wow/general_options'
