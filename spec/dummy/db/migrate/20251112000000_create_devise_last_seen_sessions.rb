# frozen_string_literal: true

class CreateDeviseLastSeenSessions < MIGRATION_CLASS
  def self.up
    create_table :devise_last_seen_sessions do |t|
      t.references :user, polymorphic: true, null: false, index: true
      t.datetime :started_at, null: false
      t.datetime :last_seen_at, null: false
      t.datetime :expires_at, null: false

      t.timestamps null: false
    end

    add_index :devise_last_seen_sessions, [:user_id, :user_type, :expires_at], name: 'index_devise_last_seen_sessions_on_user_and_expires'
  end

  def self.down
    drop_table :devise_last_seen_sessions
  end
end
