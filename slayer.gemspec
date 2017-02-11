# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slayer/version'

Gem::Specification.new do |spec|
  spec.name          = "slayer"
  spec.version       = Slayer::VERSION
  spec.authors       = ["Wyatt Kirby"]
  spec.email         = ["wyatt@apsis.io"]

  spec.summary       = %q{A killer service layer}
  spec.homepage      = "http://www.apsis.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "model_attribute", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 1.2"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "byebug", "~> 9.0"
end
