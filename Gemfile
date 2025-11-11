source 'https://rubygems.org'

# Specify your gem's dependencies in devise_last_seen.gemspec
gemspec

gem "rails", '~> 7.0'

group :test do
  gem "rack-test"
  gem "rspec-rails"
  gem "database_cleaner"
end

platforms :ruby do
  gem "sqlite3", "~> 2.8"
end

group :development do
  gem 'bundler', '~> 2.1'
  gem 'rake', '~> 13'
  gem 'rspec', '~> 3.10'
  gem 'rubocop'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end
