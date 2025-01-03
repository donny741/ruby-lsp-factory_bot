# frozen_string_literal: true

require "ruby_lsp/factory_bot/indexing_enhancement"

RSpec.describe RubyLsp::FactoryBot::IndexingEnhancement do
  subject do
    index.index_single(indexable_path, factory_definition)
    index
  end

  let(:index) { RubyIndexer::Index.new }
  let(:indexable_path) { RubyIndexer::IndexablePath.new(nil, "/spec/factories/user.rb") }
  let(:factory_definition) do
    <<~RUBY
      FactoryBot.define do
        factory :user do
          name { "John Doe" }
        end
      end
    RUBY
  end

  it "indexes the factory" do
    expect(subject.names).to include("userFactoryBot")
  end

  context 'when different class specified' do
    let(:factory_definition) do
      <<~RUBY
        FactoryBot.define do
          factory :user, class: User do
            name { "John Doe" }
          end
        end
      RUBY
    end

    it "indexes the factory" do
      expect(subject.names).to include("userFactoryBot")
    end
  end

  context "when aliases defined" do
    let(:factory_definition) do
      <<~RUBY
        FactoryBot.define do
          factory :user, aliases: %i(seller buyer) do
            name { "John Doe" }
          end
        end
      RUBY
    end

    it "includes all names of the factory" do
      expect(subject.names).to include("userFactoryBot", "sellerFactoryBot", "buyerFactoryBot")
    end

    context "when options is hash" do
      let(:factory_definition) do
        <<~RUBY
          FactoryBot.define do
            factory :user, { aliases: %i(seller buyer) } do
              name { "John Doe" }
            end
          end
        RUBY
      end

      it "includes all names of the factory" do
        expect(subject.names).to include("userFactoryBot", "sellerFactoryBot", "buyerFactoryBot")
      end
    end

    context "when trait is defined" do
      let(:factory_definition) do
        <<~RUBY
          FactoryBot.define do
            factory :user do
              name { "John Doe" }

              trait :with_email do
                email { "email@example.com" }
              end
            end
          end
        RUBY
      end

      it "indexes the factory" do
        expect(subject.names).to include("userFactoryBot", "user-t-with_emailFactoryBot")
      end

      context "with aliases" do
        let(:factory_definition) do
          <<~RUBY
            FactoryBot.define do
              factory :user, aliases: [:seller] do
                name { "John Doe" }

                trait :with_email do
                  email { "email@example.com" }
                end
              end
            end
          RUBY
        end

        it "indexes the factory" do
          expect(subject.names).to include(
            "userFactoryBot", "user-t-with_emailFactoryBot", "sellerFactoryBot", "seller-t-with_emailFactoryBot"
          )
        end
      end
    end
  end
end
