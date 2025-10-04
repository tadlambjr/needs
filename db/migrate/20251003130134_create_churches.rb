class CreateChurches < ActiveRecord::Migration[8.0]
  def change
    create_table :churches do |t|
      t.string :name, null: false
      t.text :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.string :email
      t.string :website
      t.string :timezone, default: "America/New_York"
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :churches, :name
    add_index :churches, :active
  end
end
