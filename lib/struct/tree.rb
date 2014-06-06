module Struct
  class Tree
    attr_accessor :name 
    attr_reader :children 
    
    def initialise(content)
      if content.is_a? Hash
        @name = content[:name]
        content[:children].each do  |child|

        end
      else
        @name = content
      end
    end

    def add_child(child)
      child_tree = if child.is_a? Struct::Tree
                    child
                  else
                    Struct::Tree.new(child)
                  end
      children << child_tree
    end


    alias_method :<< :add_child
  end
end