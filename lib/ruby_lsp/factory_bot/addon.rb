# frozen_string_literal: true

# parts << 'gem "ruby-lsp-factory_bot", require: false, group: :development, path: "~/Projects/ruby-lsp-factory_bot"'
require "ruby_lsp/addon"
require "ruby_lsp/internal"

require_relative "definition"
require_relative "indexing_enhancement"

module RubyLsp
  module FactoryBot
    class Addon < ::RubyLsp::Addon
      def name
        "Ruby LSP - Factory Bot"
      end

      def version
        VERSION
      end

      def activate(global_state, _message_queue)
        @index = global_state.index
        @index.register_enhancement(IndexingEnhancement.new)
      end

      def deactivate; end

      def create_definition_listener(response_builder, uri, node_context, dispatcher)
        Definition.new(response_builder, uri, node_context, @index, dispatcher)
      end
    end
  end
end
