require 'wow/install_dir'
require 'wow/source'

# Source for am installation directory.
# packages are stored in the +source+/lib
class Wow::Source::Installed < Wow::Source::Local
  def initialize(source)
    super(source)
    @dir = Wow::InstallDir.new(source)
  end

  # Used in all Wow::Source::Local methods
  # @see Wow::Source::Local#glob_packages
  def glob_packages
    packages = {}
    Dir.chdir @dir.lib do
      Dir.glob('*').each do |folder|
        next unless File.directory?(folder)
        begin
          pkg = Wow::Package.new(File.expand_path(folder), self)
          tuple = pkg.spec.name_tuple
          packages[tuple] = pkg
        rescue SystemCallError
          puts "Error while reading #{folder}"
        end
      end
    end
    packages
  end
end
