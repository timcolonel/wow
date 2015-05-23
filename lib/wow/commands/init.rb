require 'wow'
require 'wow/command'

# Command to Initialize a new Wow package
# Will create a new config file in the working dir.
class Wow::Command::Init < Wow::Command
  self.banner = "Usage: #{Wow.exe} init [options]"


  def self.parse(argv = ARGV)
    parse_options(argv)
    Wow::Command::Init.new
  end

  def initialize

  end

  def run
    src = Wow::Config.template_path('packages.toml')
    dst = File.join(Dir.pwd, Wow::Package::Specification.filename)
    if File.exist? dst
      unless agree("#{Wow::Package::Specification.filename} already exists in this folder are you sure you want to override it? [yn]")
        return
      end
    end
    FileUtils.cp(src, dst)
    puts "Created config successfully in #{Wow::Package::Specification.filename}"
  end

end
