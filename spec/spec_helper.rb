require 'bundler/setup'

if ENV['CC_TEST_REPORTER_ID'] || ENV['COVERAGE']
  begin
    require 'simplecov'

    SimpleCov.start
  rescue LoadError
    puts 'simplecov was not loaded, are you in CI? Check out the gem.yml config'
    puts 'we will only run coverage for latest ruby and rails versions ;)'
  end
end

require 'devise_last_seen'
require 'rack/test'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'
end
