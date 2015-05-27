require 'wow/package/specification'
require 'wow/package_resolver'
require 'wow/command'
require 'wow/command_option'

# Install command
class Wow::Command::Install < Wow::Command
  arguments 'install <package>'

  option :version, 'Specify the version you want to install'
  flag_option :prerelease, 'If the installed should be allowed to install prerelease', short: false

  general_option Wow::SourceOptions

  def initialize(params)
    super(params)
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
