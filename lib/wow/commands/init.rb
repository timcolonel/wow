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
      unless shell.yes?("#{Wow::Package::Specification.filename} already exists in this folder are you sure you want to override it? [yn]")
        return
      end
    end
    FileUtils.cp(src, dst)
    puts "Created config successfully in #{Wow::Package::Specification.filename}"
  end
end
