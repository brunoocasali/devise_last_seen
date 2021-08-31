require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

require 'migration_helper'
require 'rspec/rails'
require 'database_cleaner'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :feature

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.use_transactional_examples = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  ensure
    DatabaseCleaner.clean
  end

  config.before do
    Warden.test_mode!
  end

  config.after do
    Warden.test_reset!
  end
end
