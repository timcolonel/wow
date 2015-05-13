require 'wow/api_client'
module Wow::ApiClient::Config
  class << self
    attr_accessor :remote
    attr_accessor :username
    attr_accessor :password
  end
end