require 'wow/command_option'

# Option for commands that need to read to a remote
class Wow::CommandOption::RemoteReadOption < Wow::CommandOption
  self.doc = <<docopt
  -r --remote=<remote>       Override the remote for this command
  --add-remote=<remote>      Append a new remote for this command
docopt

  add_option :remote, '--remote'
  add_option :add_remote, '--add-remote'

  def self.load_options(options)
    Wow.sources.replace(options[source].split(',')) unless options[:source].nil?
    Wow.sources << options[:add_source] unless options[:add_source].nil?
  end
end

