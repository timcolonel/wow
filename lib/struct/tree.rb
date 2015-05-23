# Class representing a tree of node with multiples childrens
class Tree
  attr_accessor :name
  attr_reader :children

  def initialize(content = nil)
    @children = []
    unless content.is_a? Hash
      @name = content
      return
    end
    content.deep_symbolize_keys!
    if content.key?(:name)
      @name = content[:name]
      content[:children].each do |child|
        add_child child
      end if content.key?(:children)
    elsif content.length == 1
      @name, children = content.first
      children.each do |child|
        add_child child
      end
    else
      fail Wow::Error, 'Tree has wrong format
                        Cannot be a Hash with more than 2 key not being :name and :children.'
    end
  end

  def add_child(child)
    child_tree = if child.is_a? Tree
                   child
                 else
                   Tree.new(child)
                 end
    @children << child_tree
    self
  end

  def deep_symbolize
    out = Tree.new
    out.name = @name.to_sym if @name.respond_to?(:to_sym)
    @children.each do |child|
      out << child.deep_symbolize
    end
    out
  end

  # Symbolize the keys of all the node in the tree.
  def deep_symbolize!
    @name = @name.to_sym
    @children.each(&:deep_symbolize!)
    self
  end

  # Recursively look for a node with the given name
  # @param key [String] name of the node to look for.
  # This is using a deep first search.
  def find(key)
    return self if @name == key
    @children.each do |child|
      next unless child.respond_to?(:find)
      match = child.find(key)
      return match unless match.nil?
    end
    nil
  end

  # Check if the tree contains a node with the givent name
  # @param key [String] name of the node to look for.
  def exist?(key)
    !find(key).nil?
  end

  # Convert the tree to a Hash with 2 key: name and children
  def to_hash
    {name: @name, children: @children.map(&:to_hash)}
  end

  def to_s
    to_hash.to_s
  end

  private

  alias_method :<<, :add_child
end
