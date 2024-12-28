# frozen_string_literal: true

require "ruby_lsp/factory_bot/definition"

RSpec.describe RubyLsp::FactoryBot::Definition do
  subject { generate_definitions_for_source(source, location, uri) }

  let(:uri) { Kernel.URI("file:///spec/factories/users.rb") }

  let(:source) do
    <<~RUBY
      RSpec.describe User do
        let(:user) { create(:user) }
      end

      FactoryBot.define do
        factory :user do
          name { "John Doe" }
        end
      end
    RUBY
  end
  let(:location) { { line: 1, character: 25 } }

  it "returns the definition" do
    expect(subject.first).to have_attributes(
      target_uri: include(uri.path),
      target_range: have_attributes(
        start: have_attributes(line: 5, character: 2),
        end: have_attributes(line: 7, character: 5)
      )
    )
  end
end
