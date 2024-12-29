# frozen_string_literal: true

require_relative "utils"

module RubyLsp
  module FactoryBot
    class Definition
      include ::RubyLsp::Requests::Support::Common

      FACTORY_BOT_STRATEGIES = %i[
        create
        build
        build_stubbed
        attributes_for
      ].flat_map { |attr| [attr, :"#{attr}_list", :"#{attr}_pair"] }.freeze

      def initialize(response_builder, uri, node_context, index, dispatcher)
        @response_builder = response_builder
        @uri = uri
        @node_context = node_context
        @index = index
        dispatcher.register(self, :on_symbol_node_enter)
      end

      def on_symbol_node_enter(node)
        call_node = @node_context.call_node
        return unless FACTORY_BOT_STRATEGIES.include?(call_node.name)

        called_factory_name = Utils.name_from_node(call_node.arguments&.arguments&.first)
        return unless called_factory_name

        return factory_location_for(node) if node.value == called_factory_name

        trait_location_for(node, called_factory_name)
      end

      private

      def factory_location_for(node)
        @index["#{node.value}FactoryBot"]&.each do |entry|
          @response_builder << Interface::LocationLink.new(
            target_uri: URI::Generic.from_path(path: entry.file_path).to_s,
            target_range: range_from_location(entry.location),
            target_selection_range: range_from_location(entry.name_location)
          )
        end
      end

      def trait_location_for(node, called_factory_name)
        @index["#{called_factory_name}-t-#{node.value}FactoryBot"]&.each do |entry|
          @response_builder << Interface::LocationLink.new(
            target_uri: URI::Generic.from_path(path: entry.file_path).to_s,
            target_range: range_from_location(entry.location),
            target_selection_range: range_from_location(entry.name_location)
          )
        end
      end
    end
  end
end
