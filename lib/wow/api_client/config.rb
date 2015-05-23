require 'wow/api_client'

# Contains config for the api client.
# This will be set by general options via the command line or otherwise
module Wow::ApiClient::Config
  class << self
    attr_accessor :remote
    attr_accessor :username
    attr_accessor :password
  end
end
