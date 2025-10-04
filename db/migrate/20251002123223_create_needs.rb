class CreateNeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :needs do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :category, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false # 0=draft, 1=published, 2=full, 3=in_progress, 4=completed, 5=cancelled, 6=rejected
      t.integer :need_type, default: 0, null: false # 0=admin_created, 1=member_initiated
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :time_slot # 0=morning, 1=afternoon, 2=evening, 3=specific_time, 4=all_day
      t.time :specific_time
      t.string :location
      t.integer :volunteer_capacity, default: 1, null: false
      t.boolean :allow_individual_day_signup, default: false, null: false
      t.boolean :is_recurring, default: false, null: false
      t.string :recurrence_pattern
      t.date :recurrence_end_date
      t.references :parent_need, foreign_key: { to_table: :needs }
      t.datetime :approved_at
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :completed_at
      t.references :completed_by, foreign_key: { to_table: :users }
      t.references :checklist, foreign_key: true

      t.timestamps
    end
    
    add_index :needs, :status
    add_index :needs, :start_date
    add_index :needs, :need_type
  end
end
