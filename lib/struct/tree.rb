class Tree
  attr_accessor :name
  attr_reader :children

  def initialize(content = nil)
    @children = []
    if content.is_a? Hash
      content.deep_symbolize_keys!
      @name = content[:name]
      content[:children].each do |child|
        add_child child
      end if content.key?(:children)
    else
      @name = content
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

  def deep_symbolize!
    @name = @name.to_sym
    @children.each do |child|
      child.deep_symbolize!
    end
  end

  def find(key)
    @name == key ? self : @children.inject(nil) { |memo, v| memo ||= v.find(key) if v.respond_to?(:find) }
  end

  def to_hash
    {:name => @name, :children => @children.map(&:to_hash)}
  end

  def to_s
    to_hash.to_s
  end

  private

  alias_method :<<, :add_child
end