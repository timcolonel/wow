require 'wow'

# Class that handle the installation process of a package.
# The package must be downloaded already.
# This will just install not resolve the dependencies
# It will do the following action:
# * Extract/Copy to the package folder.
# * Link the executable
# * Link the include headers.
class Wow::Installer
  # Create a new installer
  # @param package [Wow::Package]
  # @param directory [Wow::InstallDir|String] It create the Wow::InstallDir if directory is a String
  def initialize(package, directory)
    @package = package
    @directory = directory.is_a?(Wow::InstallDir) ? directory : Wow::InstallDir.new(directory)
  end

  def install
    puts "Installing #{@package.spec.name} #{@package.spec.version}..."
    extract_to_folder
    puts "Installed #{@package.spec.name} #{@package.spec.version}"
  end

  def extract_to_folder
    if @package.archive?
      Wow::Archive.extract(@package.path, lib_folder)
    else
      fail NotImplementedError
    end
  end

  # Path to the package folder
  # e.g. $WOW_DIR/packages/lib/a-1.9.0/
  def lib_folder
    File.join(@directory.lib, @package.spec.name_tuple.folder_name)
  end
end
