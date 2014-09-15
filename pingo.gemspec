# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pingo/version'

Gem::Specification.new do |spec|
  spec.name          = "pingo"
  spec.version       = Pingo::VERSION
  spec.authors       = ["Kyuden"]
  spec.email         = ["msmsms.um@gmail.com"]
  spec.summary       = %q{Simple CLI tool for find iphone.}
  spec.description   = %q{Pingo provides a simple command for sounding your iphone.}
  spec.homepage      = "https://github.com/Kyuden/pingo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|support)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "typhoeus"
  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
