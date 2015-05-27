require 'wow'

# Options for command that need to interact with a server
# RemoteOptions differ from SourceOptions as SourceOptions can have multiple values
# while RemoteOptions is unique and must be a server.
# When to use which:
# - RemoteOptions: When you need to interact with a specific server(e.g. publishing package)
# - SourceOptions: When you want to read data from one or more location(e.g. installing a package)
class Wow::RemoteOptions < Clin::GeneralOption
  option :remote, 'Set the remote for the current command'

  def execute(options)
    return if options[:remote].nil?
    Wow.remote = options[:remote]
  end
end