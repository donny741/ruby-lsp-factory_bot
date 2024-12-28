# frozen_string_literal: true

module RubyLsp
  module FactoryBot
    class Definition
      include ::RubyLsp::Requests::Support::Common

      RSPEC_STRATEGIES = %i[create create_list build build_list build_stubbed attributes_for].freeze

      def initialize(response_builder, uri, node_context, index, dispatcher)
        @response_builder = response_builder
        @uri = uri
        @node_context = node_context
        @index = index
        dispatcher.register(self, :on_symbol_node_enter)
      end

      def on_symbol_node_enter(node)
        return unless RSPEC_STRATEGIES.include?(@node_context.call_node.name)

        @index["#{node.value}FactoryBot"]&.each do |entry|
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
