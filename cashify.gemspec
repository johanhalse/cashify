require_relative "lib/cashify/version"

Gem::Specification.new do |spec|
  spec.name          = "cashify"
  spec.version       = Cashify::VERSION
  spec.authors       = ["Johan Halse"]
  spec.email         = ["johan@hal.se"]

  spec.summary       = "A sensible way to handle money"
  spec.description   = "Money trouble no more! Add, subtract, and have fun with money in different currencies."
  spec.homepage      = "https://github.com/johanhalse/cashify"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/johanhalse/cashify"
  spec.metadata["changelog_uri"] = "https://github.com/johanhalse/cashify/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
