# frozen_string_literal: true

require_relative "lib/eve/sde/version"

Gem::Specification.new do |spec|
  spec.name = "eve-sde"
  spec.version = EVE::SDE::VERSION
  spec.authors = ["Adam Ladachowski"]
  spec.email = ["adam.ladachowski@gmail.com"]

  spec.summary = "Ruby library for EVE Online Static Data Export"
  spec.description = "Provides Ruby classes and utilities for working with EVE Online's Static Data Export (SDE)"
  spec.homepage = "https://github.com/aladac/eve-sde"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/aladac"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .standard.yml]) ||
        f.end_with?(".gem")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-struct", "~> 1.6"
  spec.add_dependency "msgpack", "~> 1.7"
  spec.add_dependency "tqdm", "~> 0.4"
  spec.add_dependency "benchmark", "~> 0.5"

  spec.add_development_dependency "irb"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.3"
  spec.add_development_dependency "simplecov"
end
