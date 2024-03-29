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

  spec.add_dependency 'devise'
end
