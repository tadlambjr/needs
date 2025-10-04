class CreateNeedSignups < ActiveRecord::Migration[8.0]
  def change
    create_table :need_signups do |t|
      t.references :need, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false # 0=signed_up, 1=waitlist, 2=cancelled, 3=completed
      t.datetime :signed_up_at, null: false
      t.datetime :cancelled_at
      t.text :cancellation_reason
      t.datetime :completed_at
      t.date :specific_date # for multi-day needs with individual day signups

      t.timestamps
    end
    
    add_index :need_signups, [:need_id, :user_id, :specific_date], unique: true, name: 'index_need_signups_uniqueness'
    add_index :need_signups, :status
  end
end
