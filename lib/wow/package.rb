require 'wow'
require 'wow/package/specification_lock'

# Package
class Wow::Package
  attr_accessor :path, :spec, :source

  # Create a new package
  # @param path [String] Path the archive (.wow) or the installed package folder
  def initialize(path, source)
    @source = source
    @path = path

    if archive?
      Wow::Archive.open @path do |archive|
        content = archive.read_file(Wow::Package::SpecificationLock.filename_in_archive(@path))
        @spec = Wow::Package::SpecificationLock.load_json(content)
      end
    else
      name_tuple = Wow::Package::NameTuple.from_folder_name(File.basename(path))
      lock_file = File.join(path, name_tuple.lock_filename)
      @spec = Wow::Package::SpecificationLock.load(lock_file)
    end
  end

  # Return if this package is already installed.
  def installed?
    @source.is_a? Wow::Source::Installed
  end

  def archive?
    @_archive ||= !File.directory?(path)
  end

  def name_tuple
    spec.name_tuple
  end

  def to_s
    name_tuple.to_s
  end
end
