require 'wow/install_dir'
require 'wow/source'

class Wow::Source::Installed < Wow::Source::Local

  def initialize(source)
    super(source)
    @dir = Wow::InstallDir.new(source)
  end

  # @see Wow::Source::Local#load_packages
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
          # ignore
        end
      end
    end
    packages
  end
end
