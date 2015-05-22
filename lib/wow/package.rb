class Wow::Package
  attr_accessor :path, :spec, :source

  def initialize(path, source)
    @source = source
    @path = path
    if File.directory? path
      name_tuple = Wow::Package::NameTuple.from_folder_name(File.basename(path))
      @spec = Wow::Package::SpecificationLock.load(File.join(path, name_tuple.lock_filename))
    else
      Wow::Archive.open @path do |archive|
        content = archive.read_file(Wow::Package::SpecificationLock.filename_in_archive(@path))
        @spec = Wow::Package::SpecificationLock.load_toml(content)
      end
    end
  end
end