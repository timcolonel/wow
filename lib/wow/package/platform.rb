module Wow
  module Package
    class Platform
      attr_accessor :name
      
      # Return true is the given platform is a parent or equals to this 
      # i.e Self is a subset of the given platform.
      # @param platform Other platform object to test
      #
      # e.g.
      # win32.is?(windows) => true
      # windows.is?(win32) => false
      # windows.is?(windows) => true
      def is?(platform)
        fail ArgumentError unless platform.is_a? Wow::Package::Platform
      end

      # This this the opposite of is?. Return true if the given platorm is a child or equals to this.
      # i.e The given platform is a subset of self
      # @param platform Other platform object to test
      #
      # e.g.
      # windows.include?(win32) => true
      # win32.include?(windows) => false
      # windows.include?(windows) => true
      def include?(platform)
        fail ArgumentError unless platform.is_a? Wow::Package::Platform
      end
    end
  end
end