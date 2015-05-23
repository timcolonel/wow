require 'wow/package/specification'
require 'wow/package_resolver'
require 'wow/command'
require 'wow/command_option'

# Install command
class Wow::Command::Install < Wow::Command
  self.doc = <<docopt
Wow install

Install the given package as well as it's dependencies.
If the package is already install it will not be updated.
This is to prevent unwanted version upgrade that might break stuff.

Usage:
  wow install <package> [Options]
  wow install (-h | --help)
Options:
  -h --help               Show this screen
  -v --version=<version>  Specify the version you want to install.
  --prerelease            If the installed should be allowed to install prerelease
#{Wow::CommandOption::RemoteReadOption.doc}
docopt

  add_general_option :remote_read

  def self.parse(argv = ARGV)
    docopt_opts = parse_options(argv)
    options = extract_general_options(docopt_opts)
    options[:package] = docopt_opts['<package>']
    options[:version] = docopt_opts['--version']
    options[:prerelease] = docopt_opts['--prerelease']
  end

  def initialize(options)
    super(options)
    @package = options[:package]
    @version = options[:version]
    @prerelease = options[:prerelease]
  end


  def run
    resolver = Wow::PackageResolver.new(:update)
    package = resolver.get_package(@package, @version, prerelease: @prerelease)
    if package.nil?
      fail Wow::Error, "No package found with this name #{package}" if @version.nil?
      fail Wow::Error, "No package found with this name #{package} and this version #{@version}"
    end

    puts "Package: #{package.name} - #{package.version}"
  end
end
