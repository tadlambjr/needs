class CreateChecklistCompletions < ActiveRecord::Migration[8.0]
  def change
    create_table :checklist_completions do |t|
      t.references :need_signup, null: false, foreign_key: true
      t.references :checklist_item, null: false, foreign_key: true
      t.boolean :completed, default: false, null: false
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end
  end
end
