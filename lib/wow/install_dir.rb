require 'wow'

# Helper class that provide path for the sub directory in the install location
class Wow::InstallDir
  def initialize(root)
    @root = root
    init_dir(bin)
    init_dir(include)
    init_dir(lib)
  end

  # Where Potential executables are linked
  def bin
    File.join(@root, 'bin')
  end

  # Where potential headers are linked
  def include
    File.join(@root, 'include')
  end

  # Where the archive are extracted.
  def lib
    File.join(@root, 'lib')
  end

  alias_method :install_path, :lib

  def init_dir(dirname)
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
  end

  def to_s
    @root
  end
end
