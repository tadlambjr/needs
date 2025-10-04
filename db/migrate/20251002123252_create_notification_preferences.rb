class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :notification_type, null: false
      t.boolean :email_enabled, default: true, null: false
      t.boolean :sms_enabled, default: false, null: false
      t.boolean :in_app_enabled, default: true, null: false

      t.timestamps
    end
    
    add_index :notification_preferences, [:user_id, :notification_type], unique: true, name: 'index_notification_prefs_uniqueness'
  end
end
