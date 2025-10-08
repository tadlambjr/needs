class AddIsOwnerToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_owner, :boolean, default: false, null: false
    add_index :users, [:church_id, :is_owner], where: "is_owner = 1"
  end
end
