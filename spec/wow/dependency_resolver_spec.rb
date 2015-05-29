require 'spec_helper'

RSpec.describe Wow::DependencyResolver do

  it '' do
    a = Wow::Package::SpecificationLock.new(name: 'a', version: '1.0.0')
    b = Wow::Package::SpecificationLock.new(name: 'b', version: '1.0.0')
    c = Wow::Package::SpecificationLock.new(name: 'c', version: '1.0.0')
    d = Wow::Package::SpecificationLock.new(name: 'd', version: '1.0.0')
  end
end
