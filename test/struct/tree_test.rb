require 'test/test_helper'
class TreeTest < ActiveSupport::TestCase

  test 'should create with name' do
    node = Tree.new(:root)
    assert node.name == :root
  end

  test 'should add a child' do
    root = Tree.new(:root)
    root << Tree.new(:children)
    assert root.children.size == 1
  end

  test 'should find value' do
    root = Tree.new(:root)
    root << Tree.new(:child1)
    root << Tree.new(:child2)

    assert_not_nil root.find(:root)
    assert_not_nil root.find(:child1)
    assert_not_nil root.find(:child1)
  end
end