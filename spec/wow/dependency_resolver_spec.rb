require 'spec_helper'


def spec(config)
  spec = Wow::Package::Specification.new
  spec.init_from_hash(config)
  spec.lock(:any)
end

RSpec.describe Wow::DependencyResolver do
  before do
    @a = spec(name: 'a', version: '1.0.0', dependencies: {b: '>= 1.0.0', c: '>= 1.0.0'})
    @b1 = spec(name: 'b', version: '1.0.9')
    @b2 = spec(name: 'b', version: '2.0.0')
    @c = spec(name: 'c', version: '1.0.0', dependencies: {b: '~> 1.0.0'})
    packages = [@a, @b1, @b2, @c].sort_by(&:version).reverse
    allow_any_instance_of(Wow::PackageResolver).to receive(:get_package) do |_, name, range|
      best = nil
      packages.each do |spec|
        if spec.name == name.to_s and range.match?(spec.version)
          best = spec
          break
        end
      end
      best.nil? ? nil : double(:package, spec: best)
    end
  end
  it '' do
    resolver = Wow::DependencyResolver.new(double(:package, spec: @a))
    resolver.resolve
    resolver
  end
end
