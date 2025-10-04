class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :phone, :string
    add_column :users, :bio, :text
    add_column :users, :role, :integer, default: 0, null: false # 0 = member, 1 = admin
    add_column :users, :email_verified, :boolean, default: false, null: false
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :timezone, :string, default: 'America/New_York'
    add_column :users, :theme_preference, :integer, default: 0, null: false # 0 = system, 1 = light, 2 = dark
  end
end
