require 'wow'

# Class that handle the UnInstallation process of a package.
# This will just uninstall the given package not anything else
# It will do the following action:
# * Delete the installation folder
# * Removed any linked executable
# * Removed any linked include header
class Wow::Uninstaller
  # Create a new uninstaller
  # @param package [Wow::Package]
  # @param directory [Wow::InstallDir|String] It create the Wow::InstallDir if directory is a String
  def initialize(package, directory)
    @package = package
    @directory = directory.is_a?(Wow::InstallDir) ? directory : Wow::InstallDir.new(directory)
  end

  def uninstall
    puts "Uninstalling #{@package.spec.name} #{@package.spec.version}..."
    remove_folder
    puts "Uninstalled #{@package.spec.name} #{@package.spec.version}"
  end

  def remove_folder
    FileUtils.rm_rf lib_folder
  end

  # Path to the package folder
  # e.g. $WOW_DIR/packages/lib/a-1.9.0/
  def lib_folder
    File.join(@directory.lib, @package.spec.name_tuple.folder_name)
  end
end
