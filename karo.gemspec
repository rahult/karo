# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'karo/version'

Gem::Specification.new do |spec|
  spec.name          = "karo"
  spec.version       = Karo::VERSION
  spec.authors       = ["Rahul Trikha"]
  spec.email         = ["rahul.trikha@gmail.com"]
  spec.description   = "SSH toolbox to make running logs, sync, cache commands easier for a given rails app"
  spec.summary       = spec.description
  spec.homepage      = "http://rahult.github.io/karo/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency  "pry"
  spec.add_development_dependency  "bundler"
  spec.add_development_dependency  "rake"
  spec.add_development_dependency  "rdoc"
  spec.add_development_dependency  "aruba"

  # spec.add_dependency "rugged",    "~> 0.21"
  spec.add_dependency "thor",      ">= 0.19", "< 2.0"
end
