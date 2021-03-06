require 'wow/package/specification'
require 'wow/package_resolver'
require 'wow/command'

# Install command
class Wow::Command::Install < Wow::Command
  arguments 'install <package>'

  option :version, 'Specify the version you want to install'
  flag_option :prerelease, 'If the installed should be allowed to install prerelease', short: false

  general_option Wow::SourceOptions

  def initialize(params)
    super(params)
    @package = params[:package]
    @version = params[:version]
    @prerelease = params[:prerelease]
  end

  def run
    resolver = Wow::PackageResolver.new(:install)
    package = resolver.get_package(@package, @version, prerelease: @prerelease)
    if package.nil?
      fail Wow::Error, "No package found with this name #{package}" if @version.nil?
      fail Wow::Error, "No package found with this name #{package} and this version #{@version}"
    end
    if package.installed?
      puts "#{package.spec.name} is already installed nothing to do!"
      return
    end
    Wow::Installer.new(package, Wow.default_install_dir).install
  end
end
