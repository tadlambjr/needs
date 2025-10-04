class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon
      t.string :color
      t.boolean :member_can_create, default: false, null: false
      t.boolean :active, default: true, null: false
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end
    
    add_index :categories, :name, unique: true
  end
end
