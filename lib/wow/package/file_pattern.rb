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
  #   Wow::Package.new('lib/**/*', 'dist')
  #   Wow::Package.new('lib/**/*' => 'dist')
  #   Wow::Package.new('lib/**/* => dist')
  def initialize(pattern, destination=nil)
    if destination and pattern.is_a? Hash
      fail ArgumentError.new ("Pattern #{pattern} cannot be a hash if the destination is already provided")
    end
    if destination
      @destination = destination
      self.pattern = pattern
    elsif pattern.is_a? Hash
      self.pattern, @destination = pattern.first
    else
      if pattern.include? '=>'
        self.pattern, @destination = pattern.split('=>', 2).map(&:strip)
      else
        self.pattern = pattern
        @destination = nil
      end
    end
  end

  def pattern=(pattern)
    @root, @wildcard = Wow::Package::FilePattern.split_pattern(pattern)
  end

  def pattern
    File.join(@root, @wildcard)
  end

  # Glob the file matching the pattern and return a Hash with the key being the file and the value it's destination
  # @param dir [String] root from where to glob the file. If nil will use the current working directory.
  # @return [String]
  #   # Current dir contains the following files lib/file1.txt, lib/sub/file2.txt
  #   p = Wow::Package.new('lib/**/*', 'dist')
  #   p.file_map  # => {'lib/file1.txt' => 'dist/file2.txt', 'lib/sub/file2.txt' => 'dist/sub/file2.txt'}
  def file_map(dir=nil)
    dir ||= Dir.pwd
    results = {}
    Dir.chdir(File.join(dir, @root)) do
      files = if @wildcard.nil? or File.directory?(@wildcard)
                Dir.glob(File.join(@wildcard, '**/*'))
              else
                Dir.glob(@wildcard)
              end
      files.each do |file|
        path = File.join(@root, file)
        results[path] = if @destination.nil?
                          path
                        else
                          File.join(@destination, file)
                        end
      end
    end
    results
  end

  # Split the pattern into the directory and the wildcard
  #   Wow::Package::FilePattern.split_pattern('lib/**/*') # => ['lib', '**/*']
  #   Wow::Package::FilePattern.split_pattern('lib/sub/**/*') # => ['lib/sub', '**/*']
  def self.split_pattern(pattern)
    segments = Pathname(pattern).each_filename.to_a
    root = nil
    wildcard = nil
    found_wildcard = false
    segments.each_with_index do |segment, i|
      if found_wildcard or segment.include? '*'
        wildcard = wildcard.nil? ? Pathname.new(segment) : wildcard + segment
        found_wildcard = true
      else
        if i == segments.size - 1 and segment.include? '.' # For the last segment it might be a filename so we check
          wildcard = Pathname.new(segment)
        else
          root = root.nil? ? Pathname.new(segment) : root + segment
        end
      end
    end
    return root.to_s, wildcard.to_s
  end
end
