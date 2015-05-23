require 'wow/source'
require 'wow/package/version_range'

# Source for a directory containing .wow package.
class Wow::Source::Local < Wow::Source

  def <=>(other)
    case other
    when Wow::Source::Installed,
      Wow::Source::Lock then
      -1
    when Wow::Source::Local then
      0
    when Wow::Source then
      1
    else
      nil
    end
  end

  # Method that load the packages in the local directory
  # @return [Hash<Wow::Package::NameTuple, Wow::Package>]
  def load_packages
    packages = {}
    Dir.chdir @source do
      Dir['*.wow'].each do |file|
        begin
          pkg = Wow::Package.new(File.expand_path(file), self)
          tuple = pkg.spec.name_tuple
          packages[tuple] = pkg
        rescue SystemCallError
          puts "Error while reading #{file}"
        end
      end
    end
    packages
  end

  # List the packages matching the filter
  def list_packages(filter)
    names = []

    @specs = load_packages
    @specs.each do |tup, pkg|
      case filter
      when :released
        names << pkg.spec.name_tuple unless pkg.spec.version.prerelease?
      when :prerelease
        names << pkg.spec.name_tuple if pkg.spec.version.prerelease?
      when :latest_release
        unless pkg.spec.version.prerelease?
          tup = pkg.spec.name_tuple

          cur = names.find { |x| x.name == tup.name }
          if !cur
            names << tup
          elsif cur.version < tup.version
            names.delete cur
            names << tup
          end
        end
      when :latest
        tup = pkg.spec.name_tuple

        cur = names.find { |x| x.name == tup.name }
        if !cur
          names << tup
        elsif cur.version < tup.version
          names.delete cur
          names << tup
        end
      else
        names << pkg.spec.name_tuple
      end
    end

    names
  end

  # @see Wow::Source#find_package
  def find_package(package_name, version_range = nil, prerelease: false)
    found = []
    version_range ||= Wow::Package::VersionRange.any
    version_range = Wow::Package::VersionRange.parse(version_range) if version_range.is_a? String
    load_packages.each do |n, pkg|
      next if n.name != package_name
      s = pkg.spec

      if version_range.include?(s.version) && (prerelease || !s.version.prerelease?)
        found << pkg
      end
    end

    found.max_by { |pkg| pkg.spec.version }
  end

  # @see Wow::Source#fetch_spec
  def fetch_spec(name)
    list_packages :complete
    if (data = @specs[name])
      data.spec
    else
      fail Wow::Error, "Unable to find spec for #{name.inspect}"
    end
  end

  # @see Wow::Source#download
  def download(spec, _cache_dir = nil)
    list_packages :complete

    @specs.each do |_, pkg|
      return pkg.path if pkg.spec == spec
    end

    fail Gem::Exception, "Unable to find file for '#{spec.full_name}'"
  end
end
