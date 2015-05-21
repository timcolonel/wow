class Wow::Package
  attr_accessor :archive_filename, :spec

  def initialize(file)
    @archive_filename = file
    Wow::Archive.open @archive_filename do |archive|
      content = archive.read_file(Wow::Package::SpecificationLock.filename_in_archive(@archive_filename))
      @spec = Wow::Package::SpecificationLock.load_toml(content)
    end
  end

end