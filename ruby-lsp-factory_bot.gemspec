# frozen_string_literal: true

require_relative "lib/ruby_lsp/factory_bot/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-lsp-factory_bot"
  spec.version = RubyLsp::FactoryBot::VERSION
  spec.authors = ["donny741"]

  spec.summary = "Ruby LSP FactoryBot Addon"
  spec.description = "Provides go to definition and completion for FactoryBot attributes in Ruby LSP"
  spec.homepage = "https://github.com/donny741/ruby-lsp-factory_bot"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(
          "bin/",
          "test/",
          "spec/",
          "features/",
          ".git",
          ".circleci",
          "appveyor",
          "Gemfile",
          "misc/",
          "sorbet/"
        )
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "ruby-lsp", "~> 0.20.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
