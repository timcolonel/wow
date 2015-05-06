
class Wow::Command::Init
  def initialize

  end

  def run
    src = Wow::Config.template_path('packages.toml')
    dst = File.join(Dir.pwd, Wow::Package::Config.filename)
    FileUtils.cp(src, dst)
  end
end