# frozen_string_literal: true

class AddNameToUsers < MIGRATION_CLASS
  def change
    add_column :users, :name, :string
  end
end
