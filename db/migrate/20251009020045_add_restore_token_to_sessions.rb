class AddRestoreTokenToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :restore_token, :string
    add_index :sessions, :restore_token, unique: true
  end
end
