require 'wow/package/specification'
require 'wow/package_resolver'
require 'wow/command'

# Install command
class Wow::Command::Uninstall < Wow::Command
  arguments 'uninstall <package>'

  option :version, 'Specify the version you want to install(all to uninstall all the versions)'
  flag_option :all, 'Will uninstall every version found without asking.'

  def initialize(params)
    super(params)
    @package = params[:package]
    @version = params[:version]
    @name_tuple = Wow::Package::NameTuple.new(@package, @version, :any)
  end

  def run
    packages = Wow.installed_sources.list_packages(@package, @version)
    fail Wow::Error, "No installed package matching '#{@name_tuple}'" if packages.empty?
    packages = handle_multiple_package(packages) if packages.size > 1
    packages.each do |package|
      Wow::Uninstaller.new(package, Wow.default_install_dir).uninstall
    end
  end

  def handle_multiple_package(packages)
    return packages if all?
    choices = ['All versions'] + packages.map(&:to_s)
    answer = shell.select('Select version to uninstall:', choices)
    return packages if answer == 'All versions'
    packages.select { |x| x.to_s == answer }
  end

  def all?
    @params[:all]
  end
end
