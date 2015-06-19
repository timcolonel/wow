require 'wow'

module Wow::Symlink
  module Default
    def File.symlink(file, symlink)
      File.symlink(file, symlink)
    end

    def File.symlink?(file)
      File.symlink?(file)
    end

    def File.readlink(file)
      File.readlink(file)
    end
  end

  module Windows
    def symlink(file, symlink)
      `cmd.exe /c mklink "#{symlink}" "#{file}"`
    end

    def symlink?(file)
      `cmd.exe /c dir #{file} | find "SYMLINK"`
    end

    def readlink(file)
    end
  end

  if OS.windows?
    extend Windows
  else
    extend Default
  end
end
