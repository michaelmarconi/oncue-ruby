# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oncue/version'

Gem::Specification.new do |gem|
  gem.name          = 'oncue'
  gem.version       = OnCue::VERSION
  gem.authors       = ['Michael Marconi']
  gem.license       = 'Apache 2.0'
  gem.email         = ['michael@modeltwozero.com']
  gem.description   = "A client for onCue\'s REST API"
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/michaelmarconi/oncue-ruby'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec', '~> 2.12.0'
  gem.add_development_dependency 'webmock', '~> 1.11.0'
  gem.add_development_dependency 'rake', '~> 0.9.2.2'

  gem.add_runtime_dependency 'addressable', '~> 2.3.3'
  gem.add_runtime_dependency 'json', '~> 1.7.7'
  gem.add_runtime_dependency 'rest-client', '~> 1.6.7'

end
