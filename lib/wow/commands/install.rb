require 'wow/package/specification'

class Wow::Command::Install
  def initialize(package, version=nil, prerelease: false)
    @package = package
    @version = version
    @prerelease = prerelease
  end

  def run
    package = Wow.sources.find_package(@package, @version, prerelease: @prerelease)
    if package.nil?
      fail Wow::Error, "No package found with this name #{package}" if @version.nil?
      fail Wow::Error, "No package found with this name #{package} and this version #{@version}"
    end

    puts "Package: #{package.name} - #{package.version}"
  end
end