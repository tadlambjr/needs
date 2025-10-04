class CreateChecklists < ActiveRecord::Migration[8.0]
  def change
    create_table :checklists do |t|
      t.string :name, null: false
      t.text :description
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
