class Wow::Source
  # Load a list of specs in the source
  # @param filter [Symbol] filter the packages.
  #   Can have the following values: :release, :prerelease, :latest_release, :latest
  def load_specs(filter)
    raise NotImplementedError
  end

  # Load a list of specs in the source
  def find_package(package_name, version_range = Wow::Package::VersionRange.any, prerelease: false)
    raise NotImplementedError
  end

  def fetch_spec(name)
    raise NotImplementedError
  end
end