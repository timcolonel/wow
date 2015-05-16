require 'tempfile'

module Tmp
  class Folder

    attr_accessor :relative_path
    attr_accessor :fullpath

    def initialize(name = nil, parent = nil)
      if name.nil?
        name = SecureRandom.uuid
      end
      unless parent.nil?
        name = File.join(parent.relative_path, name)
      end
      @relative_path = name
      @fullpath = File.join(Tmp::Folder.tmp_dir, name)
      self.clean
      FileUtils.mkdir_p(@fullpath)
    end

    def sub_folder(name)
      Tmp::Folder.new(name, self)
    end

    def path(path)
      File.join(@fullpath, path)
    end

    def file(filename=nil)
      if filename.nil?
        filename = "#{SecureRandom.uuid}.tmp"
      end
      path(filename)
    end

    def random(prefix: nil, extension: 'tmp')
      array = []
      array << prefix if prefix
      array << SecureRandom.uuid
      array << extension if extension
      path(array.join('.'))
    end

    # Create temporary files
    # @param count [Integer] number of files to create
    # @param absolute [Boolean] set to true to return absolute path, set to false to return relative path to the folder
    # @return [List<String>] list of the file paths in absolute or relative form depending on the abolute flag
    def create_files(count: 1, absolute: true)
      filenames = []
      count.times.each do |i|
        filename = random(prefix: i)
        filenames << if absolute
                       filename
                     else
                       root = Pathname.new(Wow::Config::ROOT_FOLDER)
                       Pathname.new(filename).relative_path_from(root).to_s
                     end
        File.open filename, 'w' do |f|
          f.write Random.rand
        end
      end
      filenames
    end

    def self.tmp_dir
      "#{File.dirname(__FILE__)}/tmp/"
    end

    def clean
      FileUtils.rm_rf @fullpath
    end

    def to_s
      @fullpath
    end
  end
end
class TmpFile

  def self.clean(folder)
    FileUtils.rm_rf File.join(tmp_folder, folder)
  end

  #Return the path of a new file in the tmp folder
  def self.path(filename = '', folder = '')
    _folder = File.join(tmp_folder, folder)
    FileUtils.mkdir_p(_folder) unless File.directory?(_folder)
    File.join(_folder, "#{SecureRandom.uuid}-#{filename}")
  end

  #Return a folder path
  def self.folder_path(folder)
    if folder.nil? or folder.empty?
      tmp_folder
    else
      File.join(tmp_folder, folder)
    end
  end

  def self.tmp_folder
    "#{File.dirname(__FILE__)}/tmp/"
  end

  # Create temporary files
  # @param count [Integer] number of files to create
  # @param folder [String] folder inside the tmp folder where to create the files into
  # @param absolute [Boolean] set to true to return absolute path, set to false to return relative path to the folder
  # @return [List<String>] list of the file paths in absolute or relative form depending on the abolute flag
  def self.create_files(count: 1, folder: '', absolute: true)
    filenames = []
    count.times.each do |i|
      filename = path(i, folder)
      filenames << if absolute
                     filename
                   else
                     root = Pathname.new(Wow::Config::ROOT_FOLDER)
                     Pathname.new(filename).relative_path_from(root).to_s
                   end
      File.open filename, 'w' do |f|
        f.write Random.rand
      end
    end
    filenames
  end
end