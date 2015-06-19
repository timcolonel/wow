require 'wow'

class Wow::ExecutableManager
  # @param dir [Wow::InstallDir]
  def initialize(dir)
    @dir = dir
  end

  def create_executables(package)
    package.spec.executables.each do |exe|
      create_executable(File.join(package.name_tuple.folder_name, exe))
    end
  end

  def create_executable(filename)
    generate_bin_symlink(filename)
  end

  def exe_location(filename)
    File.join(@dir.bin, File.basename(filename))
  end

  def generate_bin_symlink(filename)
    src = File.join(@dir.lib, filename)
    dst = exe_location(filename)

    if File.exist? dst
      Wow::Symlink.unlink(dst)
    end

    Wow::Symlink.symlink src, dst
  end
end
