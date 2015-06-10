require 'docopt'
require 'wow/command'
require_rel 'commands'


# Parse the entire command line
# It will extract which action should be called and then pass it the CL
class Wow::CommandParser < Wow::Command
  skip_options true
  arguments '<command> [<args>...]'

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
    @args = []
    @args << @command unless @command.nil?
    @args += params[:args] unless params[:args].nil?
    @args += params[:skipped_options]
  end

  def run
    if %w(-v --version).include? @command
      puts "Version: #{Wow::VERSION}"
      exit
    end
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


