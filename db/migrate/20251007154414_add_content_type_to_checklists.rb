class AddContentTypeToChecklists < ActiveRecord::Migration[8.0]
  def change
    add_column :checklists, :content_type, :integer, default: 0, null: false
    add_index :checklists, :content_type
  end
end
