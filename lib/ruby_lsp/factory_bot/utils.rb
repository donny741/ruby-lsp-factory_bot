# frozen_string_literal: true

module Utils
  module_function

  def name_from_node(name_node)
    case name_node
    when Prism::StringNode
      name_node.content
    when Prism::SymbolNode
      name_node.value
    end
  end
end
