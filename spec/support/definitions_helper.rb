# frozen_string_literal: true

module DefinitionsHelper
  def generate_definitions_for_source(source, position, uri = nil)
    with_server(source, uri) do |server, uri|
      server.global_state.index.index_single(URI::Generic.from_path(path: uri.path), source)
      server.process_message(
        id: 1,
        method: "textDocument/definition",
        params: { textDocument: { uri: uri }, position: position }
      )

      result = pop_result(server)
      result.response
    end
  end

  def pop_result(server)
    result = server.pop_response
    result = server.pop_response until result.is_a?(RubyLsp::Result) || result.is_a?(RubyLsp::Error)

    raise result if result.is_a?(RubyLsp::Error)

    result
  end
end
