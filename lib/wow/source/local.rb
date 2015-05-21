require 'wow/source'
require 'wow/package/version_range'
class Wow::Source::Local < Wow::Source

  def initialize(folder)
    @folder = folder
  end

  def <=> (other)
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

  # @see Wow::Source#load_spec
  def load_specs(filter)
    names = []

    @specs = {}
    Dir.chdir @folder do
      Dir['*.wow'].each do |file|
        begin
          pkg = Wow::Package.new(file)
        rescue SystemCallError
          # ignore
        else
          tup = pkg.spec.name_tuple
          @specs[tup] = [File.expand_path(file), pkg]

          case filter
            when :released
              unless pkg.spec.version.prerelease?
                names << pkg.spec.name_tuple
              end
            when :prerelease
              if pkg.spec.version.prerelease?
                names << pkg.spec.name_tuple
              end
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
      end
    end

    names
  end

  # @see Wow::Source#find_package
  def find_package(package_name, version_range = Wow::Package::VersionRange.any, prerelease: false)
    load_specs :complete
    found = []
    version_range = Wow::Package::VersionRange.parse(version_range) if version_range.is_a? String
    @specs.each do |n, data|
      if n.name == package_name
        s = data[1].spec

        if version_range.include?(s.version)
          if prerelease
            found << s
          elsif !s.version.prerelease?
            found << s
          end
        end
      end
    end

    found.max_by { |s| s.version }
  end

  # @see Wow::Source#fetch_spec
  def fetch_spec(name)
    load_specs :complete
    if (data = @specs[name])
      data.last.spec
    else
      raise Gem::Exception, "Unable to find spec for #{name.inspect}"
    end
  end

  # @see Wow::Source#download
  def download(spec, cache_dir = nil)
    load_specs :complete

    @specs.each do |_, data|
      return data[0] if data[1].spec == spec
    end

    raise Gem::Exception, "Unable to find file for '#{spec.full_name}'"
  end
end