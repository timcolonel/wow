require 'wow'

class Wow::Package::VersionRange
  # Module that contains all the pattern for the version range
  module Patterns
    extend ActiveSupport::Concern
    # Class methods used to register patterns
    module ClassMethods
      attr_accessor :patterns

      def register_pattern(name, regex, &block)
        @patterns ||= []
        @patterns << [name, regex, block]
      end
    end

    included do
      register_pattern :more_equal, /\A>= (.*)\Z/x do |version|
        Wow::Package::VersionRange.new(lower_bound: version, include: {lower_bound: true})
      end

      register_pattern :more, /\A> (.*)\Z/x do |version|
        Wow::Package::VersionRange.new(lower_bound: version, include: {lower_bound: false})
      end

      register_pattern :less_equal, /\A<= (.*)\Z/x do |version|
        Wow::Package::VersionRange.new(upper_bound: version, include: {upper_bound: true})
      end

      register_pattern :less, /\A< (.*)\Z/x do |version|
        Wow::Package::VersionRange.new(upper_bound: version, include: {upper_bound: false})
      end

      register_pattern :tilt, /\A~> (.*)\Z/x do |version|
        Wow::Package::VersionRange.new(lower_bound: version,
                                       upper_bound: version.pessimistic_upgrade)
      end

      # Need to be last as it's the more general value(The equal operator is optional)
      register_pattern :equal, /\A=? (.*)\Z/x do |version|
        Wow::Package::VersionRange.new(version)
      end
    end
  end
end
