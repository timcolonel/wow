require 'highline/import'
require 'rest-client'
require 'wow/api_client'

class Wow::Command::Register
  def initialize

  end

  def run
    client = Wow::ApiClient.new
    client.sign_in
    result =  client.get('/api/v1/tags')
    puts result
    # puts result.code
    # puts result.cookies
    # puts result

    # puts '==='
    # result = RestClient.get URI.join(Wow::Config.remote, '/api/v1/tags').to_s, content_type: :json, accept: :json, cookies: result.cookies
    # puts result
  end
end