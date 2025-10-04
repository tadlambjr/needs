class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :notification_type, null: false # 0=new_need, 1=reminder, 2=signup_confirmation, 3=cancellation, 4=need_modified, 5=approval_status
      t.string :title, null: false
      t.text :message, null: false
      t.string :related_type # polymorphic
      t.integer :related_id # polymorphic
      t.boolean :read, default: false, null: false
      t.datetime :read_at

      t.timestamps
    end
    
    add_index :notifications, [:user_id, :read]
    add_index :notifications, [:related_type, :related_id]
  end
end
