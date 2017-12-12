lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_struct/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_struct'
  spec.version       = ApiStruct::VERSION
  spec.authors       = ['bezrukavyi']
  spec.email         = ['yaroslav.bezrukavyi@gmail.com']

  spec.summary       = 'Api entities'
  spec.description   = 'Api entities'
  spec.homepage      = 'https://github.com/bezrukavyi'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-monads', '>= 0.3.1'
  spec.add_dependency 'dry-configurable', '>= 0.7'
  spec.add_dependency 'http', '>= 2.0.3'
  spec.add_dependency 'hashie', '~> 3.5', '>= 3.5.6'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
end
