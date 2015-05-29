require 'spec_helper'


def spec(config)
  spec = Wow::Package::Specification.new
  spec.init_from_hash(config)
  spec.lock(:any)
end

def pkg(config)
  double(:package, spec: spec(config))
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

  describe '#satify?' do
    let (:a) { double(:package, spec: spec(name: 'a', version: '1.0.0')) }
    let (:b) { double(:package, spec: spec(name: 'b', version: '2.0.0')) }
    subject { Wow::DependencyResolver.new(a) }

    before do
      subject.instance_variable_set(:@current_packages, {'a' => a, 'b' => b})
    end

    it { expect(subject.satisfy?(Wow::Package::Dependency.new('a', '>= 1.0.0'))).to be true }
    it { expect(subject.satisfy?(Wow::Package::Dependency.new('b', '>= 1.0.0'))).to be true }
    it { expect(subject.satisfy?(Wow::Package::Dependency.new('b', '>= 2.1.0'))).to be false }
    it { expect(subject.satisfy?(Wow::Package::Dependency.new('d', '>= 1.0.0'))).to be false }
  end

  describe '#remaining_dependencies' do
    let(:a) { pkg(name: 'a', version: '1.0.0', dependencies: {b: '>= 1.0.0', c: '>= 1.0.0'}) }
    let(:b) { pkg(name: 'b', version: '2.0.0') }
    let(:c) { pkg(name: 'c', version: '1.0.0', dependencies: {b: '~> 1.0.0'}) }
    subject { Wow::DependencyResolver.new(a) }

    before do
      subject.instance_variable_set(:@current_packages, {'a' => a, 'b' => b})
    end

    it { expect(subject.remaining_dependencies.size).to be 1 }
    it { expect(subject.remaining_dependencies.first.name).to eq('c') }
    context 'when all dependencies are here but 1 has wrong version' do
      before do
        subject.instance_variable_get(:@current_packages)['c'] = c
      end
      it { expect(subject.remaining_dependencies.size).to be 1 }
      it { expect(subject.remaining_dependencies.first.name).to eq('b') }
      it 'need the version required by c' do
        expect(subject.remaining_dependencies.first.version_range)
          .to eq(Wow::Package::VersionRange.parse('~> 1.0.0'))
      end
    end
  end
end
