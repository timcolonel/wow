class Wow::Command::Init
  def initialize

  end

  def run
    src = Wow::Config.template_path('packages.toml')
    dst = File.join(Dir.pwd, Wow::Package::Config.filename)
    if File.exist? dst
      unless agree("#{Wow::Package::Config.filename} already exists in this folder are you sure you want to override it? [yn]")
        return
      end
    end
    FileUtils.cp(src, dst)
    puts "Created config successfully in #{Wow::Package::Config.filename}"
  end
end