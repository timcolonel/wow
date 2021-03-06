require 'wow'
require 'wow/command'

# Command to Initialize a new Wow package
# Will create a new config file in the working dir.
class Wow::Command::Init < Wow::Command
  arguments 'init'

  def run
    src = Wow::Config.template_path('packages.toml')
    dst = File.join(Dir.pwd, Wow::Package::Specification.filename)
    if File.exist? dst
      keep = shell.keep?(dst) do
        File.read(src)
      end
      return if keep
    end
    FileUtils.cp(src, dst)
    puts "Created config successfully in #{Wow::Package::Specification.filename}"
  end
end
