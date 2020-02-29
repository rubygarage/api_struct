lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_struct/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_struct'
  spec.version       = ApiStruct::VERSION
  spec.authors       = %w[bezrukavyi andy1341 kirillshevch]
  spec.email         = ['yaroslav.bezrukavyi@gmail.com', 'andrii.novikov1341@gmail.com', 'kirills167@gmail.com']

  spec.summary       = 'API wrapper builder with response serialization'
  spec.description   = spec.description
  spec.homepage      = 'https://github.com/rubygarage/api_struct'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-monads', '~> 1'
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'dry-inflector'
  spec.add_dependency 'http'
  spec.add_dependency 'hashie'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'pry-byebug', '~> 3.5', '>= 3.5.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.52.0'
  spec.add_development_dependency 'vcr', '~> 3.0.3'
  spec.add_development_dependency 'webmock', '~> 3.2', '>= 3.2.1'
  spec.add_development_dependency 'ffaker', '~> 2.7'
end
