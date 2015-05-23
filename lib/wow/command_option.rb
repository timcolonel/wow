require 'wow'

# Template class for reusable option across command.
# Each CommandOption must have the following step:
# * Doc to insert into the command docopt
# * Parsing of the docopt options into more programing friendly keys(--remote to :remote)
# * Extracting back the options into their corresponding global container
class Wow::CommandOption
  class_attribute :doc
  class_attribute :options_map

  self.options_map = {}

  # Remap docopt options into the more programming friendly keys
  def self.extract_docopt_options(docopt)
    options = {}
    options_map.each do |k, v|
      options[v] = docopt[k]
    end
    options
  end

  # Load the options into the corresponding global container.
  # @param options [Hash] options for the command containing some/all the option for this class
  def self.load_options(_options)
    fail NotImplementedError
  end

  def self.add_option(option, docopt_option)
    options_map[docopt_option] = option
  end
end

require_rel 'command_option'
