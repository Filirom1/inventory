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
  spec.homepage      = "https://github.com/Filirom1/inventory"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'midi-smtp-server', '~> 1.1'
  spec.add_dependency 'rest-client', '~> 1.7'
  spec.add_dependency 'gserver', '~> 0.0'
  spec.add_dependency 'mail', '~> 2.6'
  spec.add_dependency 'filum', '~> 2.2'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'libxml-to-hash', '~> 0.2'
  spec.add_dependency 'middleware', '~> 0.1'
  spec.add_dependency 'sinatra', '~> 1.4'
  spec.add_dependency 'ensure-encoding', '~> 0.1'
  spec.add_dependency 'json-schema', '~> 2.5'
  spec.add_dependency 'unicorn', '~> 4.8'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.2"
  spec.add_development_dependency "webmock", "~> 1.20"
  spec.add_development_dependency 'parallel', '~> 1.4'
end
