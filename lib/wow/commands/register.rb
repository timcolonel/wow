require 'rest-client'
require 'wow/api_client'
require 'wow/command'

# Command that handle the registration of a package
class Wow::Command::Register < Wow::Command
  arguments 'register'

  general_option Wow::RemoteOptions

  def run
    config = Wow::Specification.load_valid!

    client = Wow::ApiClient.new
    client.sign_in
    unless shell.yes?("Are you sure you want to register '#{config.name}'? [yn]")
      return
    end
    begin
      response = client.post 'api/v1/packages',
                             name: config.name,
                             homepage: config.homepage,
                             short_description: config.short_description,
                             description: config.description,
                             tags: config.tags,
                             authors: config.authors
      puts "Registered package #{config.name} with success! The url is #{response.data[:url]}."
    rescue RestClient::Exception => e
      raise Wow::UnprocessableEntity.new(config.name, e.response.data)
    end
  end
end
