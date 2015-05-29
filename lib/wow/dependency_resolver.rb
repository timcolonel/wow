require 'wow'

# Resolve dependencies from a starting packages
class Wow::DependencyResolver
  def initialize(package)
    @inital_package = package
    @current_packages = {}
    update_package(package)
  end

  def resolve
    package_resolver = Wow::PackageResolver.new
    loop do
      rem = remaining_dependencies
      break if rem.empty?
      rem.each do |dep|
        package = package_resolver.get_package(dep.name, dep.version_range)
        update_package(package)
      end
    end
  end

  def update_package(package)
    @current_packages[package.spec.name] = package
  end

  # Get the list of the dependencies that are not yet satisfied!
  # @return [Array<Wow::Package::Dependency]
  def remaining_dependencies
    dependencies = []
    @current_packages.each do |_, package|
      package.spec.dependencies.each do |dep|
        next if satisfy? dep
        dependencies << dep
      end
    end
    dependencies
  end

  # Check if the resolver current status satisfy the given dependency
  # @param dependency [Wow::Package::Dependency]
  # @return [Boolean]
  def satisfy?(dependency)
    return false unless @current_packages.key? dependency.name.to_s
    dependency.satisfied_by?(@current_packages[dependency.name.to_s].spec)
  end
end

