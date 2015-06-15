require 'uri'
require 'wow/exception'

# Rest-Client overlay to connect to a wow api server.
class Wow::ApiClient
  attr_accessor :sources
  attr_accessor :default_source
  attr_reader :current_source
  attr_accessor :username
  attr_accessor :password

  def initialize
    @sources = { local: 'http://localhost:3000' }
    @default_source = @sources[:local]
    @current_source = Wow::ApiClient::Config.remote || default_source
    @current_user = nil
  end

  def current_source=(new_source)
    if @sources.key? new_source
      @current_source = @sources[new_source]
    elsif new_source =~ URI.regexp
      @current_source = new_source
    else
      fail ArgumentError("The given source '#{new_source}' is neither a key in the existing defined sources nor a url!")
    end
  end

  # Will prompt the user for its credentials then attempt to sign in.
  def sign_in
    puts "Enter your '#{Wow::Config.remote}' credentials."
    puts "Don't have an account yet? Create one at #{Wow::Config.remote}/users/sign_up"
    email = Wow::ApiClient::Config.username || shell.ask("\tEmail: ")
    password = Wow::ApiClient::Config.password || shell.password("\tPassword: ")
    begin
      result = post('users/sign_in', email: email, password: password)
      data = result.data
      @current_user = { id: data[:id], token: data[:authentication_token] }
    rescue RestClient::Unauthorized => e
      raise Wow::Error, e.response.data[:error]
    end
  end

  def shell
    @shell ||= Clin::Shell.new
  end

  # Get request to the specified path using the current_source as a root.
  # @param params: Param to send with the request. Also include headers.
  def get(path, params = {})
    execute :get, path, params
  end

  def post(path, params = {}, headers = {})
    execute :post, path, params, headers
  end

  def put(path, params = {}, headers = {})
    execute :put, path, params, headers
  end

  def patch(path, params = {}, headers = {})
    execute :patch, path, params, headers
  end

  def delete(path, params = {})
    execute :get, path, params
  end

  def execute(method, path, params = {}, headers = {})
    result = if [:get, :delete, :head, :options].include? method
               RestClient.send(method, url(path), internal_params.merge(params).merge(headers))
             else
               RestClient.send(method, url(path), params.to_json, internal_params.merge(headers))
             end
    result.extend Wow::ApiClient::Response
    result
  rescue RestClient::Exception => e
    e.response.extend Wow::ApiClient::Response
    raise e
  end

  def auth_headers
    if @current_user.nil?
      {}
    else
      { :'X-User-Id' => @current_user[:id], :'X-User-Token' => @current_user[:token] }
    end
  end

  def internal_params
    { content_type: :json, accept: :json }.merge(auth_headers)
  end

  def url(path)
    URI.join(current_source, path).to_s
  end
end

require 'wow/api_client/response'
require 'wow/api_client/config'
