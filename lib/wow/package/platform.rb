require 'yaml'

module Wow
  module Package
    class Platform
      attr_accessor :name

      # platform.is?(other) => Boolean
      # Return true is the given platform is a parent or equals to this 
      # i.e Self is a subset of the given platform.
      # @param platform [Wow::Package::Platform] Other platform object to test
      # @return [Boolean]
      # e.g.
      #   win32.is?(windows)    => true
      #   windows.is?(win32)    => false
      #   windows.is?(windows)  => true
      def is?(platform)
        fail ArgumentError unless platform.is_a? Wow::Package::Platform
      end

      # This this the opposite of is?. Return true if the given platform is a child or equals to this.
      # i.e The given platform is a subset of self
      # @param platform Other platform object to test
      #
      # e.g.
      #   windows.include?(win32)   => true
      #   win32.include?(windows)   => false
      #   windows.include?(windows) => true
      #
      def include?(platform)
        fail ArgumentError unless platform.is_a? Wow::Package::Platform
      end

      class << self
        def platforms
          if @platforms.nil?
            @platforms = YAML.load_file(Wow::Config.asset_path('platforms.yml')).deep_symbolize_keys
          end
          @platforms
        end
      end
    end
  end
end

