require 'wow/api_client/config'
require 'optparse'


# Command handler
class Wow::Command < Clin::Command
  abstract true
  exe_name Wow.exe

  general_option Clin::HelpOptions
end

