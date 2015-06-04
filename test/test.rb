require 'thor'

shell =  Thor::Shell::Basic.new
puts shell.yes?('Some?', '\e[31m')
