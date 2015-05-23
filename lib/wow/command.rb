require 'wow/api_client/config'
require 'optparse'


# Command handler
class Wow::Command
  # Note the following attributes are not shared between subclass
  # Contain the docopt for the command
  class_attribute :banner

  # List of options that are reused across several command(e.g. remote, email, password, etc.)
  class_attribute :options

  # List of options that are reused across several command(e.g. remote, email, password, etc.)
  class_attribute :general_options

  # If the command should fail if there are unknown options.
  # It is useful to have nested command.
  # The parent will then have true and child will be able to define custom options
  class_attribute :authorize_unknown_options

  self.general_options = Set.new
  self.authorize_unknown_options = false

  def initialize(options)
    @options = options
    load_general_options(options)
  end

  def self.add_general_option(command_option)
    if command_option.is_a?(Class) && !(command_option < Wow::CommandOption)
      fail Wow::Error, "Command option #{command_option} must be of type Command::Option"
    end
    cls_name = "#{command_option}_option".classify
    command_option = "Wow::CommandOption::#{cls_name}".constantize
    general_options << command_option
  end

  def self.add_option(name, *args)
    options << [name, args]
  end

  # Parse the options using the doc attribute of the class
  def self.parse_options(argv, params = {})
    opts = {}
    opt_parser = OptionParser.new do |o|
      o.banner = banner

      options.each do |name, args|
        o.on(*args) do |value|
          opts[name] = value
        end
      end
    end

    argv = opt_parser.parse(argv)
  end

  def self.extract_general_options(docopt_options)
    options = {}
    general_options.each do |general|
      options.merge!(general.extract_docopt_options(docopt_options))
    end
    options
  end

  def self.load_general_options(options)
    general_options.each do |general|
      general.load_options(options)
    end
  end

  def extract_common_options
    Wow::ApiClient::Config.remote = @options['--remote']
    Wow::ApiClient::Config.username = @options['--username']
    Wow::ApiClient::Config.password = @options['--password']
    Wow.sources.replace(@options['--source'].split(',')) unless @options['--source'].nil?
    Wow.sources << @options['--add-source'] unless @options['--add-source'].nil?
  end
end

