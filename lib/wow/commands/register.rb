require 'highline/import'
require 'rest-client'
require 'wow/api_client'
require 'wow/command'

# Command that handle the registration of a package
class Wow::Command::Register < Wow::Command
  self.doc = <<DOCOPT
Wow register

Register the package to the server.

Usage:
    #{Wow.exe} register
    #{Wow.exe} register (-h | --help)
Options:
  -h --help                 Show this screen.

DOCOPT

  def self.parse(argv = ARGV)
    parse_options(argv)
    Wow::Command::Init.new
  end


  def initialize

  end

  def run
    config = Wow::Specification.load_valid!

    client = Wow::ApiClient.new
    client.sign_in
    return unless agree("Are you sure you want to register this '#{config.name}' with this name? [yn]")
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
