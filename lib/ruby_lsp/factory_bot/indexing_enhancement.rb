# frozen_string_literal: true

module RubyLsp
  module FactoryBot
    class IndexingEnhancement < RubyIndexer::Enhancement

      FACTORIES_PATH = "spec/factories"

      def on_call_node_enter(node)
        @inside_define_block = true if node.message == "define"
        return unless @inside_define_block
        return unless node.message == "factory"

        resolve_factory_names(node)&.each do |factory_name|
          @listener.add_method(
            "#{factory_name}FactoryBot",
            node.location,
            [RubyIndexer::Entry::Signature.new([])],
          )
        end
      end

      def on_call_node_leave(node)
        @inside_define_block = false if node.message == "define"
      end

      private

      def resolve_factory_names(node)
        arguments = node.arguments&.arguments
        return unless arguments

        factory_names = []
        factory_names << name_from_node(arguments.first)

        keyword_hash_node = arguments.find { |argument| argument.type == :keyword_hash_node }
        return factory_names unless keyword_hash_node

        aliases_node = keyword_hash_node.elements.find { |element| name_from_node(element.key) == "aliases" }&.value
        return unless aliases_node

        case aliases_node
        when Prism::ArrayNode
          factory_names += aliases_node.elements.map { |element| name_from_node(element) }
        when Prism::SymbolNode, Prism::StringNode
          factory_names << name_from_node(aliases_node)
        end

        factory_names
      end

      def name_from_node(name_node)
        case name_node
        when Prism::StringNode
          name_node.content
        when Prism::SymbolNode
          name_node.value
        end
      end
    end
  end
end
