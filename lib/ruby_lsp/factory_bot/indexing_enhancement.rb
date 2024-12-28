# frozen_string_literal: true

module RubyLsp
  module FactoryBot
    class IndexingEnhancement
      include RubyIndexer::Enhancement

      FACTORIES_PATH = "spec/factories"

      def on_call_node(index, owner, node, file_path, code_units_cache)
        return unless file_path.include?(FACTORIES_PATH)

        return unless node.message == "factory"

        resolve_factory_names(node)&.each do |factory_name|
          index.add(
            RubyIndexer::Entry::Method.new(
              "#{factory_name}FactoryBot",
              file_path,
              RubyIndexer::Location.from_prism_location(node.location, code_units_cache),
              RubyIndexer::Location.from_prism_location(node.location, code_units_cache),
              nil,
              [RubyIndexer::Entry::Signature.new([])],
              RubyIndexer::Entry::Visibility::PUBLIC,
              owner
            )
          )
        end
      end

      private

      def resolve_factory_names(node)
        arguments = node.arguments&.arguments
        return unless arguments

        factory_names = []
        factory_names << name_from_node(arguments.first)
        return factory_names unless arguments[1]&.type == :keyword_hash_node || arguments[1]&.type == :hash

        aliases_node = arguments[1].elements.find { |element| name_from_node(element.key) == "aliases" }
        return unless aliases_node

        case aliases_node.value
        when Prism::ArrayNode
          factory_names += aliases_node.value.elements.map { |element| name_from_node(element) }
        when Prism::SymbolNode, Prism::StringNode
          factory_names << name_from_node(aliases_node.value)
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
