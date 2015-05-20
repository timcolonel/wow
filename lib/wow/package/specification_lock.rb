class Wow::Package::SpecificationLock

  attr_accessor :target, :files, :executables, :version, :authors, :tags, :homepage, :description, :short_description

  def initialize(platform, architecture=nil)
    @target = if platform.nil? or not platform.is_a? Wow::Package::Platform
                Wow::Package::Platform.new(platform, architecture)
              else
                platform
              end
    @files = Set.new
    @executables = Set.new
    @tags = Set.new
    @authors = Set.new
  end

  # @param [Wow::Package::Specification]
  def insert_specification(specification)
    @name ||= specification.name
    @version ||= specification.version
    @homepage ||= specification.homepage
    @description ||= specification.description
    @short_description ||= specification.short_description

    @tags += specification.tags
    @authors += specification.authors

    @files += specification.files.values
    @executables += specification.executables
  end

  def to_hash
    {target: target.to_hash,
     version: @version.to_s,
     authors: @authors.to_a,
     tags: @tags.to_a,
     homepage: @homepage.to_s,
     description: @description,
     short_description: @short_description,
     files: @files.to_a,
     executables: @executables.to_a}
  end

  def filename
    @arch = nil
    array = [@name]
    if @target and @target.platform != :any
      array << @target.platform
      if @target.architecture and @target.architecture != :any
        array << @target.architecture
      end
    end

    "#{array.join('-')}-.lock.toml"
  end

  def save
    @files << filename
    File.open filename, 'w' do |f|
      f.write(TOML.dump(self.to_hash))
    end
  end
end