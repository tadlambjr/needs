class RemoveGlobalUniqueIndexFromCategories < ActiveRecord::Migration[8.0]
  def change
    # Remove the global unique index on name (keeping the church-scoped one)
    remove_index :categories, :name, if_exists: true
  end
end
