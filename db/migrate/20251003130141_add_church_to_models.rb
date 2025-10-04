class AddChurchToModels < ActiveRecord::Migration[8.0]
  def change
    # Add church_id columns as nullable first (index is created automatically)
    add_reference :categories, :church, foreign_key: true, index: false
    add_reference :needs, :church, foreign_key: true
    add_reference :checklists, :church, foreign_key: true
    
    # Assign existing records to the default church
    reversible do |dir|
      dir.up do
        default_church = Church.find_by(name: 'Oikos Community Church')
        
        if default_church
          Category.where(church_id: nil).update_all(church_id: default_church.id)
          Need.where(church_id: nil).update_all(church_id: default_church.id)
          Checklist.where(church_id: nil).update_all(church_id: default_church.id)
        end
      end
    end
    
    # Now make them non-nullable
    change_column_null :categories, :church_id, false
    change_column_null :needs, :church_id, false
    change_column_null :checklists, :church_id, false
    
    # Add composite unique index for categories (we disabled the simple index above)
    add_index :categories, [:church_id, :name], unique: true
  end
end
