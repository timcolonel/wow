module Wow
  class Runner
    ACTIONS = [
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
      fail Wow::Error, 'Unknown command'
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

    end

    def uninstall

    end

    def update

    end

    def updgrade

    end
  end
end