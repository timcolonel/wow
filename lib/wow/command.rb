require 'wow/api_client/config'
module Wow
  class Command
    ACTIONS = [
        :init,
        :pack,
        :register,
        :install,
        :build,
        :extract,
        :uninstall
    ]

    ALIASES = {
        instal: :install,
        uninstal: :uninstall
    }

    def initialize(options)
      @options = options
    end

    def extract_common_options
      Wow::ApiClient::Config.remote = @options['--remote']
      Wow::ApiClient::Config.username = @options['--username']
      Wow::ApiClient::Config.password = @options['--password']
    end

    def run
      extract_common_options
      compute_actions.each do |al, action|
        if @options[al.to_s]
          return self.send(action).run
        end
      end
      fail Wow::UnknownCommand, 'Unknown command'
    end

    def compute_actions
      ACTIONS.inject({}) { |hash, x| hash.update(x => x) }.merge(ALIASES)
    end

    #Extract the given filename to the installation folder
    def extract(filename)
      extractor = Wow::Extractor.new(filename)
      extractor.extract
    end

    def init
      Wow::Command::Init.new
    end

    def pack
      Wow::Command::Pack.new(@options['<platform>'])
    end

    def register
      Wow::Command::Register.new
    end

    def build

    end

    def install
      puts 'Ins'
    end

    def uninstall

    end

    def update

    end

    def updgrade

    end
  end
end

require_rel 'commands'
