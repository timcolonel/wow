require 'wow/package/specification'
require 'wow/package_resolver'
require 'wow/command'
require 'wow/command_option'

# Install command
class Wow::Command::Uninstall < Wow::Command
  arguments 'uninstall <package>'

  option :version, 'Specify the version you want to install(all to uninstall all the versions)'

  general_option Wow::SourceOptions

  def initialize(params)
    super(params)
    @package = params[:package]
    @version = params[:version]
  end

  def run
    packages = Wow.installed_sources.list_packages(@package, @version)
    if package.nil?
      fail Wow::Error, "No package found with this name #{package}" if @version.nil?
      fail Wow::Error, "No package found with this name #{package} and this version #{@version}"
    end
    if package.installed?
      puts "#{package.spec.name} is already installed nothing to do!"
    end
    Wow::Installer.new(package, Wow.default_install_dir).install
  end
end
