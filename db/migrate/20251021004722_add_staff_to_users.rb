class AddStaffToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :staff, :boolean, default: false, null: false
  end
end
