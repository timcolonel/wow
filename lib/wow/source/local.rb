require 'wow/source'
require 'wow/package/version_range'

# Source for a directory containing .wow package.
class Wow::Source::Local < Wow::Source
  # @see Wow::Source#find_package
  def list_packages(package_name, version_range = nil, prerelease: false)
    found = []
    version_range = Wow::Package::VersionRange.parse(version_range)
    glob_packages.each do |n, pkg|
      next if n.name != package_name
      s = pkg.spec

      if version_range.include?(s.version) && (prerelease || !s.version.prerelease?)
        found << pkg
      end
    end
    found
  end

  # @see Wow::Source#download
  def download(spec, _cache_dir = nil)
    glob_packages.each do |_, pkg|
      return pkg.path if pkg.spec == spec
    end

    fail Gem::Exception, "Unable to find file for '#{spec.full_name}'"
  end

  # Scan all the packages in the directory
  # @return [Hash<Wow::Package::NameTuple, Wow::Package>]
  def glob_packages
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
end
