class CreateChecklistItems < ActiveRecord::Migration[8.0]
  def change
    create_table :checklist_items do |t|
      t.references :checklist, null: false, foreign_key: true
      t.text :description, null: false
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end
    
    add_index :checklist_items, [:checklist_id, :display_order]
  end
end
