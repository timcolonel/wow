require 'wow/package/version'

class Wow::Package::NameTuple
  include Comparable
  attr_accessor :name, :version, :target

  def initialize(name, version, target)
    @name = name
    @version = version
    @target = target
  end

  def self.from_archive_name(archive_filename)
    fail ArgumentError, 'The archive extension should be .wow' if File.extname(archive_filename) != '.wow'
    from_folder_name(File.basename(archive_filename, '.wow'))
  end

  def self.from_folder_name(folder)
    segments = folder.split('-')
    fail ArgumentError 'Name is wrong should be <name>-<version>' if segments.size < 2
    name = segments[0]
    version = Wow::Package::Version.parse(segments[1])
    target = if segments.size > 2
               platform = segments[2]
               arch = if segments.size > 3
                        segments[3]
                      else
                        nil
                      end
               Wow::Package::Target.new(platform, arch)
             else
               nil
             end
    Wow::Package::NameTuple.new(name, version, target)
  end

  def archive_filename
    "#{folder_name}.wow"
  end

  def folder_name
    @arch = nil
    array = [@name, @version]
    if @target && @target.platform != :any
      array << @target.platform
      if @target.architecture && @target.architecture != :any
        array << @target.architecture
      end
    end
    array.join('-')
  end

  def lock_filename
    @arch = nil
    array = [@name]
    if @target && @target.platform != :any
      array << @target.platform
      if @target.architecture && @target.architecture != :any
        array << @target.architecture
      end
    end

    "#{array.join('-')}.lock.json"
  end

  def <=>(other)
    to_a <=> other.to_a
  end

  def ==(other)
    return to_a == other if other.is_a? Array
    @name == other.name && @version == other.version && @target == other.target
  end

  alias_method :eql?, :==

  def to_a
    [@name, @version, @target]
  end

  def hash
    to_a.hash
  end

  def to_s
    to_a.compact.reject { |x| x == :any }.join('-')
  end
end
