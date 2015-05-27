require 'wow/source/installed'
module Wow

  def self.default_remote
    'https://localhost:3000'
  end

  def self.default_sources
    Wow::SourceList.from [Wow::Source::Remote.new(self.default_remote)]
  end

  def self.default_installed_source
    Wow::SourceList.from [Wow::Source::Installed.new(Wow.default_install_dir)]
  end

  def self.default_install_dir
    File.join(Wow::Config::ROOT_FOLDER, 'packages')
  end
end