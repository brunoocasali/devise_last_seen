require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

require 'rspec/rails'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :feature

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.use_transactional_examples = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before do
    Warden.test_mode!
  end

  config.after do
    Warden.test_reset!
  end
end

Dir["#{Dir.pwd}/spec/support/**/*.rb"].sort.each { |f| require f }
