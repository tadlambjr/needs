class CreateRoomBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :room_bookings do |t|
      t.references :need, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.references :requested_by, null: false, foreign_key: { to_table: :users }
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.text :notes

      t.timestamps
    end
    
    add_index :room_bookings, [:need_id, :room_id], unique: true
    add_index :room_bookings, :status
  end
end
