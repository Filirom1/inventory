# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inventory/server/version'

Gem::Specification.new do |spec|
  spec.name          = "inventory-server"
  spec.version       = Inventory::Server::VERSION
  spec.authors       = ["Filirom1"]
  spec.email         = ["filirom1@gmail.com"]
  spec.summary       = %q{Inventory server store and index data sent from the agent}
  spec.description   = %q{Inventory server store and index data sent from the agent}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'midi-smtp-server'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'gserver'
  spec.add_dependency 'mail'
  spec.add_dependency 'filum'
  spec.add_dependency 'json'
  spec.add_dependency 'crack'
  spec.add_dependency 'middleware'
  spec.add_dependency 'app_configuration'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'thin'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.20"
end
