# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oncue/version'

Gem::Specification.new do |gem|
  gem.name          = "oncue"
  gem.version       = OnCue::VERSION
  gem.license       = "MIT"
  gem.authors       = ["Michael Marconi"]
  gem.email         = ["michael@modeltwozero.com"]
  gem.description   = %q{A Ruby API for the onCue job scheduling framework}
  gem.summary       = %q{This API allows you to communicate with a Redis-backed onCue intance, in order to enqueue and monitor jobs}
  gem.homepage      = "https://github.com/michaelmarconi/oncue-api"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '~> 2.12.0'
  gem.add_runtime_dependency 'redis', '~> 3.0.2'
end
