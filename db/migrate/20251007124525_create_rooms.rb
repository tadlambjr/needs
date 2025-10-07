class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.text :description
      t.integer :capacity
      t.references :church, null: false, foreign_key: true
      t.boolean :active, default: true, null: false
      t.string :location

      t.timestamps
    end
    
    add_index :rooms, [:church_id, :name], unique: true
    add_index :rooms, :active
  end
end
