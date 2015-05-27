require 'wow'

# Options for command that need to interact with a server
class Wow::SourceOptions < Clin::GeneralOption
  option :source, 'Override all the sources'
  option :add_source, 'Add a source to the end of the source list', short: false, long: '--add-source'

  def execute(options)
    Wow.sources.replace(options[:source].split(',')) unless options[:source].nil?
    Wow.sources << options[:add_source] unless options[:add_source].nil?
  end
end