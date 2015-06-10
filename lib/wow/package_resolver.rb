class Wow::PackageResolver
  METHODS = [:install, :update]

  def initialize(method = :install)
    @method = method
  end

  def self.find_installed_package(name, version_range = nil, prerelease: nil)
    Wow.installed_sources.find_package(name, version_range, prerelease: prerelease)
  end

  def self.find_source_package(name, version_range = nil, prerelease: nil)
    Wow.sources.find_package(name, version_range, prerelease: prerelease)
  end

  def get_package(name, version_range = nil, prerelease: nil)
    installed_package = self.class.find_installed_package(name, version_range, prerelease: prerelease)
    if @method == :install && installed_package
      installed_package
    else
      source = self.class.find_source_package(name, version_range, prerelease: prerelease)
      fail Wow::Error, "Cannot resolve package #{name}" if source.nil?
      source
    end
  end
end
