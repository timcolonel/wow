# @author Timothee Guerin
# Class for pattern matching of files
# Contains a pattern e.g. lib/**/*
# Can also have a destination folder
# e.g. If pattern == lib/**/* and destination = 'dist' then all the files in lib will be moved to dist
class Wow::Package::FilePattern
  attr_accessor :root
  attr_accessor :wildcard
  attr_accessor :destination

  # File pattern can be set in multiple way.
  # @param pattern [String|Hash] Pattern matching files. Can either be a wildcard or a folder.
  # @param destination [String] Destination folder. nil to keep location.
  #
  # There are multiple ways to set the destination. The following are equivalent:
  # ```
  #  Wow::Package.new('lib/**/*', 'dist')
  #  Wow::Package.new('lib/**/*' => 'dist')
  #  Wow::Package.new('lib/**/* => dist')
  # ```
  def initialize(pattern, destination=nil)
    if destination
      @destination = destination
      self.pattern = pattern
    elsif pattern.is_a? Hash
      self.pattern, @destination = pattern.first.map(&:to_s)
    else
      if pattern.include? '=>'
        self.pattern, @destination = pattern.split('=>', 2).map(&:strip)
      else
        self.pattern = pattern
        @destination = nil
      end
    end
  end

  #
  # Setter for the pattern. Split the pattern in root and wildcard, see {Wow::Package::FilePattern.split_pattern}
  # @param pattern [String] pattern to set
  def pattern=(pattern)
    @root, @wildcard = Wow::Package::FilePattern.split_pattern(pattern)
  end

  # Pattern getter.
  # @return [String]
  def pattern
    if @root.blank?
      @wildcard
    else
      File.join(@root, @wildcard)
    end
  end

  # Glob the file matching the pattern and return a Hash with the key being the file and the value it's destination
  # @param dir [String] root from where to glob the file. If nil will use the current working directory.
  # @return [String]
  # ```
  #   # Current dir contains the following files lib/file1.txt, lib/sub/file2.txt
  #   p = Wow::Package.new('lib/**/*', 'dist')
  #   p.file_map  # => {'lib/file1.txt' => 'dist/file2.txt', 'lib/sub/file2.txt' => 'dist/sub/file2.txt'}
  # ```
  def file_map(dir = nil)
    dir ||= Dir.pwd
    results = {}
    Dir.chdir(File.join(dir, @root)) do
      files = if @wildcard.nil? || File.directory?(@wildcard)
                Dir.glob(File.join(@wildcard, '**/*'))
              else
                Dir.glob(@wildcard)
              end
      files.each do |file|
        next unless File.file? file
        path = root.blank? ? file : File.join(@root, file)
        results[path] = @destination.nil? ? path : File.join(@destination, file)
      end
    end
    results
  end

  # Split the pattern into the directory and the wildcard:
  # ```
  #   Wow::Package::FilePattern.split_pattern('lib/**/*') # => ['lib', '**/*']
  #   Wow::Package::FilePattern.split_pattern('lib/sub/**/*') # => ['lib/sub', '**/*']
  # ```
  def self.split_pattern(pattern)
    pathname = Pathname(pattern.to_s)
    segments = pathname.each_filename.to_a
    root = pathname.absolute? ? Pathname('/') : nil
    wildcard = nil
    found_wildcard = false
    segments.each_with_index do |segment, i|
      if found_wildcard || segment.include?('*')
        wildcard = wildcard.nil? ? Pathname.new(segment) : wildcard + segment
        found_wildcard = true
      else
        if i == segments.size - 1 # For the last segment it might be a filename so we check
          wildcard = Pathname.new(segment)
        else
          root = root.nil? ? Pathname.new(segment) : root + segment
        end
      end
    end
    [root.to_s, wildcard.to_s]
  end
end
