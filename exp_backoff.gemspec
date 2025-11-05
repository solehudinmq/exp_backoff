# frozen_string_literal: true

require_relative "lib/exp_backoff/version"

Gem::Specification.new do |spec|
  spec.name = "exp_backoff"
  spec.version = ExpBackoff::VERSION
  spec.authors = ["SolehMQ"]
  spec.email = ["solehudinmq@gmail.com"]

  spec.summary = "Exp backoff is a Ruby library that implements a retry mechanism with an exponential backoff strategy. Its purpose is to exponentially increase the wait time between each failed retry attempt. This ensures the system's resilience to failures and allows the affected service time to fully recover."
  spec.description = "With the Exp backoff library, our applications now have the ability to perform retry processes automatically. This retry strategy works well in combination with circuit breakers and rollback mechanisms when the number of retry failures reaches a maximum."
  spec.homepage = "https://github.com/solehudinmq/exp_backoff"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "httparty", "~> 0.21"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
