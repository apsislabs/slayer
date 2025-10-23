lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "slayer/version"

Gem::Specification.new do |spec|
  spec.name = "slayer"
  spec.version = Slayer::VERSION
  spec.authors = ["Wyatt Kirby", "Noah Callaway"]
  spec.email = ["wyatt@apsis.io", "noah@apsis.io"]

  spec.summary = "A killer service layer"
  spec.homepage = "http://www.apsis.io"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bigdecimal"
  spec.add_dependency "ostruct"
  spec.add_dependency "virtus", "~> 2.0"

  spec.add_development_dependency "bundler", ">= 2.2.0"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake", "~> 13.3"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "standard"

  spec.metadata["rubygems_mfa_required"] = "true"
end
