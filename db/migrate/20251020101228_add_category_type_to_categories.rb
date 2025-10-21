class AddCategoryTypeToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :category_type, :integer, default: 0, null: false
    
    # Set existing categories to 'need' type (0)
    reversible do |dir|
      dir.up do
        execute "UPDATE categories SET category_type = 0"
      end
    end
  end
end
