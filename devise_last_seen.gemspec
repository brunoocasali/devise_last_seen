lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'devise_last_seen/version'

Gem::Specification.new do |spec|
  spec.name          = 'devise_last_seen'
  spec.version       = DeviseLastSeen::VERSION
  spec.authors       = ['Bruno Casali']
  spec.email         = ['brunoocasali@gmail.com']

  spec.summary       = 'Ensure that devise will update a flag/timestamp on the model whenever a user is authenticated.'
  spec.description   = 'Ensure that devise will update a flag/timestamp on the model whenever a user is authenticated.'
  spec.homepage      = 'https://github.com/brunoocasali/devise_last_seen'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.1.0'

  spec.files = Dir['{app,config,lib}/**/*', 'CHANGELOG.md', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'devise'

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'sqlite3'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rack-test', '~> 1'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rspec-rails', '~> 5'

  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
end
