require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
migrations_path = File.expand_path('dummy/db/migrate', __dir__)

unless Rails.gem_version >= Gem::Version.new('7.2.0')
  raise "Unsupported Rails version: #{Rails.version}, expected 7.2.0 or higher. Please upgrade your Rails version."
end

ActiveRecord::MigrationContext.new(migrations_path).migrate

DatabaseCleaner[:active_record].strategy = :transaction
