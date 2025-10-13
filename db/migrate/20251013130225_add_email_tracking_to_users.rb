class AddEmailTrackingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_bounce_status, :integer, default: 0, null: false
    add_column :users, :email_bounced_at, :datetime
    add_column :users, :email_complaint_at, :datetime
    add_column :users, :email_suppressed, :boolean, default: false, null: false
    add_column :users, :last_email_sent_at, :datetime
    add_column :users, :bounce_count, :integer, default: 0, null: false
    
    add_index :users, :email_suppressed
    add_index :users, :email_bounce_status
  end
end
