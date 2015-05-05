require 'test/test_helper'
class TreeTest < ActiveSupport::TestCase

  test 'should create with name' do
    node = Tree.new(:root)
    assert node.name == :root
  end

  test 'should create a tree from hash, Method 1' do
    node = Tree.new(root: [
                        :child1,
                        {child2: [
                            :sub_child1,
                            :sub_child2
                        ]}
                    ])
    assert node.name == :root
    assert_not_nil node.find(:child1)
    assert_not_nil node.find(:child2)
    assert_not_nil node.find(:sub_child1)
  end

  test 'should create a tree from hash, Method 2' do
    child2 = {name: 'child2',
              children: [
                  {name: 'sub_child1'},
                  {name: 'sub_child2'}
              ]}
    node = Tree.new(name: 'root',
                    children: [{name: 'child1'}, child2])
    node.deep_symbolize!
    assert node.name == :root
    assert_not_nil node.find(:child1)
    assert_not_nil node.find(:child2)
    assert_not_nil node.find(:sub_child1)
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


  test 'should deep symbolize names (Destructive)' do
    tree = Tree.new('root')
    tree << Tree.new('child1')
    tree << Tree.new('child2')
    tree.deep_symbolize!

    assert_kind_of Symbol, tree.name
    tree.children.each do |child|
      assert_kind_of Symbol, child.name
    end
  end

  test 'should deep symbolize names in another tree (Non destructive)' do
    tree = Tree.new('root')
    tree << Tree.new('child1')
    tree << Tree.new('child2')
    sym_tree = tree.deep_symbolize

    assert_kind_of Symbol, sym_tree.name
    sym_tree.children.each do |child|
      assert_kind_of Symbol, child.name
    end

    #Check non destruction
    tree.children.each do |child|
      assert_kind_of String, child.name
    end
  end

  test 'should return hash' do
    hash = Tree.new(:root).add_child(:child1).add_child(:child2).to_hash
    assert_not_nil hash
    assert_kind_of Hash, hash
    assert hash.has_key?(:name)
    assert hash.has_key?(:children)
  end

  test 'test #to_s method' do
    assert_nothing_raised do
      Tree.new(:root).add_child(:child1).add_child(:child2).to_s
    end
  end
end