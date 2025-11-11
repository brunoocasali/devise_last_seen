# frozen_string_literal: true
# frozen_string_literal: true

class AddDeviseToAdmins < MIGRATION_CLASS
  def self.up
    create_table :admins do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Last seen (will have the column but not active)
      t.datetime :last_seen

      # Uncomment below if timestamps were not included in your original model.
      t.timestamps null: false
    end

    add_index :admins, :email,                unique: true
    add_index :admins, :reset_password_token, unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
