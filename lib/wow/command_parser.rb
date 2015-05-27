require 'docopt'
require 'wow/command'
require_rel 'commands'


# Parse the entire command line
# It will extract which action should be called and then pass it the CL
class Wow::CommandParser < Wow::Command

  arguments '<command> [<args>...]'
  <<DOCOPT
Wow

Usage:
    #{Wow.exe} <command> [<args>...]
    #{Wow.exe} (-v | --version)
    #{Wow.exe} (-h | --help)
Options:
  -h --help                 Show this screen.
  -v --version              Show version
  -s --source=<source>      Set the source for the package. Override the user config
  --add-source=<source>     Add a source to the list of sources.
  -u --username=<username>  Username for remote
  -p --password=<password>  Password for remote
  --prerelease              Authorize to install prerelease
DOCOPT

  cattr_accessor :actions
  cattr_accessor :aliases

  self.actions = [
      :init,
      :pack,
      :register,
      :install,
      :build,
      :extract,
      :uninstall
  ]

  self.aliases = {
      instal: :install,
      uninstal: :uninstall
  }

  def initialize(params)
    super(params)
    @command = params[:command]
    @args = [@command]
    @args += params[:args] unless params[:args].nil?
  end

  def run
    cls = command_cls
    cls.parse(@args).run
  end

  protected

  def command_cls
    command_cls_name.constantize
  end

  def command_cls_name
    cmd = command_map[@command.to_sym]
    fail Wow::UnknownCommand, "Unknown command #{@command}" if cmd.nil?
    "Wow::Command::#{cmd.to_s.classify}"
  end

  def command_map
    actions.inject({}) do |a, e|
      a.update(e => e)
    end.merge(Wow::CommandParser.aliases)
  end
end


