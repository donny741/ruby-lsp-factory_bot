# frozen_string_literal: true

require_relative "utils"

module RubyLsp
  module FactoryBot
    class IndexingEnhancement < RubyIndexer::Enhancement
      def initialize(...)
        super
        @inside_define_block = false
        @factory_stack = []
      end

      FACTORIES_PATH = "spec/factories"

      def on_call_node_enter(node)
        @inside_define_block = true if node.message == "define"
        return unless @inside_define_block

        case node.message
        when "factory"
          @factory_stack << register_factory(node)
        when "trait"
          register_trait(node)
        end
      end

      def on_call_node_leave(node)
        @inside_define_block = false if node.message == "define"
        @factory_stack.pop if node.message == "factory"
      end

      private

      def register_factory(node)
        factory_names = resolve_factory_names(node)
        factory_names&.each do |factory_name|
          @listener.add_method(
            "#{factory_name}FactoryBot",
            node.location,
            [RubyIndexer::Entry::Signature.new([])]
          )
        end

        factory_names
      end

      def resolve_factory_names(node)
        arguments = node.arguments&.arguments
        return unless arguments

        factory_names = []
        factory_names << Utils.name_from_node(arguments.first)

        keyword_hash_node = arguments.find do |argument|
          argument.type == :keyword_hash_node || argument.type == :hash_node
        end
        return factory_names unless keyword_hash_node

        aliases_node = keyword_hash_node.elements.find do |element|
          Utils.name_from_node(element.key) == "aliases"
        end&.value
        return factory_names unless aliases_node

        case aliases_node
        when Prism::ArrayNode
          factory_names += aliases_node.elements.map { |element| Utils.name_from_node(element) }
        when Prism::SymbolNode, Prism::StringNode
          factory_names << Utils.name_from_node(aliases_node)
        end

        factory_names
      end

      def register_trait(node)
        return if !current_factory_names || current_factory_names.empty?

        arguments = node.arguments&.arguments
        return unless arguments

        trait_name = Utils.name_from_node(arguments.first)
        return unless trait_name

        current_factory_names.each do |factory_name|
          @listener.add_method(
            "#{factory_name}-t-#{trait_name}FactoryBot",
            node.location,
            [RubyIndexer::Entry::Signature.new([])]
          )
        end
      end

      def current_factory_names
        @factory_stack.last
      end
    end
  end
end
