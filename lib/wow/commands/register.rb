require 'highline/import'
require 'rest-client'
require 'wow/api_client'

class Wow::Command::Register
  def initialize

  end

  def run
    config = Wow::Package::Config.new
    config.init_from_toml(Wow::Package::Config.filename)
    config.validate!

    client = Wow::ApiClient.new
    client.sign_in
    return unless agree("Are you sure you want to register this '#{config.name}' with this name? [yn]")
    begin
      response = client.post 'api/v1/packages', {name: config.name,
                                                 homepage: config.homepage,
                                                 short_description: config.short_description,
                                                 description: config.description,
                                                 tags: config.tags,
                                                 authors: config.authors}
      puts "Registered package #{config.name} with success! The url is #{response.data[:url]}."
    rescue RestClient::Exception => e
      raise Wow::UnprocessableEntity.new(config.name, e.response.data)
    end
  end
end