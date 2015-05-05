module Wow
  class Command
    ACTIONS = [
        :init,
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

    def run
      compute_actions.each do |al, action|
        if @options[al.to_s]
          return self.send(action)
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