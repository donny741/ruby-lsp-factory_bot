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
        dispatcher.register(self, :on_symbol_node_enter, :on_call_node_enter)
      end

      def on_symbol_node_enter(node)
        return unless (call_node = @node_context&.call_node)

        case call_node.name
        when *FACTORY_BOT_STRATEGIES then factory_or_trait_location_for(call_node, node)
        when :generate then sequence_location_for(node.value)
        end
      end

      def on_call_node_enter(node)
        return unless @node_context&.call_node&.message == "factory"
        return if node.arguments || node.block

        factory_location_for(node.message)
      end

      private

      def factory_or_trait_location_for(call_node, node)
        called_factory_name = Utils.name_from_node(call_node.arguments&.arguments&.first)
        return unless called_factory_name

        return factory_location_for(node.value) if node.value == called_factory_name

        trait_location_for(node.value, called_factory_name)
      end

      def factory_location_for(factory_name)
        @index["#{factory_name}FactoryBot"]&.each do |entry|
          @response_builder << Interface::LocationLink.new(
            target_uri: URI::Generic.from_path(path: entry.file_path).to_s,
            target_range: range_from_location(entry.location),
            target_selection_range: range_from_location(entry.name_location)
          )
        end
      end

      def trait_location_for(trait_name, called_factory_name)
        @index["#{called_factory_name}-t-#{trait_name}FactoryBot"]&.each do |entry|
          @response_builder << Interface::LocationLink.new(
            target_uri: URI::Generic.from_path(path: entry.file_path).to_s,
            target_range: range_from_location(entry.location),
            target_selection_range: range_from_location(entry.name_location)
          )
        end
      end

      def sequence_location_for(sequence_name)
        @index["#{sequence_name}-s-FactoryBot"]&.each do |entry|
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
