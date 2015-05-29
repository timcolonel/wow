require 'wow'

# Resolve dependencies from a starting packages
class Wow::DependencyResolver
  def initialize(spec)
    @inital_package = spec
    @current_packages = {}
    update_package(spec)
  end

  def resolve
    package_resolver = Wow::PackageResolver.new
    @dependencies.each do |name, version_range|
      package = package_resolver.get_package(name, version_range)
      package.spec.dependencies
    end
  end

  def update_package(package)
    @current_packages[package.spec.name] = package
  end

  def remaining_dependencies
    dependencies = []
    @current_packages.each do |_, package|
      package.dependencies.each do |dep|
        next if satisfy? dep
        dependencies << dep
      end
    end
  end

  def satisfy?(dependency)
    return false unless @current_packages.key? dependency.name
    dependency.satisfied_by?(@current_packages[dependency.name])
  end
end

