# FactoryBot add-on

The FactoryBot add-on is a [Ruby LSP](https://github.com/Shopify/ruby-lsp) [add-on](https://shopify.github.io/ruby-lsp/add-ons.html) for extra FactoryBot editor features.

## Installation

If you haven't already done so, you'll need to first [set up Ruby LSP](https://shopify.github.io/ruby-lsp/#usage).

Add the following to your application's Gemfile:
```ruby
# Gemfile
gem "ruby-lsp-factory_bot", require: false, group: :development
```

run `bundle install` and restart Ruby LSP server.

## Features

- [x] Go-to-definition for factories
- [x] Go-to-definition for factory traits
- [ ] Completions for factories and traits

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
