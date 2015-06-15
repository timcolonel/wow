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

  # Get the package matching the best the query
  # If in install mode and the package is already installed
  # it will return the installed package and not check the sources
  # If in update mode it will get the package with the highest version.
  # If source version is the same as the installed package it will return the installed package.
  def get_package(name, version_range = nil, prerelease: nil)
    installed_package = self.class.find_installed_package(name, version_range, prerelease: prerelease)
    if installing? && installed_package
      installed_package
    else
      package = self.class.find_source_package(name, version_range, prerelease: prerelease)
      fail Wow::Error, "Cannot resolve package #{name}" if package.nil?
      if installed_package && installed_package.name_tuple == package.name_tuple
        return installed_package
      end
      package
    end
  end

  def installing?
    @method == :install
  end

  def updating?
    @method == :update
  end
end
