module Wow
  class Validation
    class << self
      def validates_presence_of(*attributes)
        @validates_presences ||= []
        @validates_presences += attributes
      end

      def validate_with_regex(*attributes, regex)
    end
  end
end