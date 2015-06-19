require 'wow/package/specification'

class Wow::Command::Pack < Wow::Command
  option :target, 'Build the package for a specific target(platform[-architecture]'

  def initialize(params)
    super
    @target = Wow::Package::Target.new(params[:target])
  end

  def run
    config = Wow::Package::Specification.load_valid!
    archive_path = config.create_archive(@target, destination: Dir.pwd)
    puts "Created archive in #{archive_path}"
  end
end
