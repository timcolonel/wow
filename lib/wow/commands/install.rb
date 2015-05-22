require 'wow/package/specification'
require 'wow/package_resolver'

class Wow::Command::Install
  def initialize(package, version=nil, prerelease: false)
    @package = package
    @version = version
    @prerelease = prerelease
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