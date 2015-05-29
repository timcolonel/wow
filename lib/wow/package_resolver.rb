class Wow::PackageResolver
  METHODS = [:install, :update]

  def initialize(method=:install)
    @method = method
  end

  def find_installed_package(name, version_range = nil, prerelease: nil)
    Wow.installed_sources.find_package(name, version_range, prerelease: prerelease)
  end

  def find_source_package(name, version_range = nil, prerelease: nil)
    Wow.sources.find_package(name, version_range, prerelease: prerelease)
  end

  def get_package(name, version_range = nil, prerelease: nil)
    installed_package = find_installed_package(name, version_range, prerelease: prerelease)
    if @method == :install and installed_package
      installed_package
    else
      source = find_source_package(name, version_range, prerelease: prerelease)
      fail Wow::Error, "Cannot resolve package #{name}" if source.nil?
      source
    end
  end
end
