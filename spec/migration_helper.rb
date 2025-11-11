require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
migrations_path = File.expand_path('dummy/db/migrate', __dir__)

if Rails.gem_version >= Gem::Version.new('7.2.0')
  ActiveRecord::MigrationContext.new(migrations_path).migrate
else
  raise "Unsupported Rails version: #{Rails.version}, expected 7.2.0 or higher. Please upgrade your Rails version."
end

DatabaseCleaner[:active_record].strategy = :transaction
