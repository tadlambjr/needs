class AddContentTypeToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :content_type, :integer, default: 0, null: false
    add_index :needs, :content_type
  end
end
