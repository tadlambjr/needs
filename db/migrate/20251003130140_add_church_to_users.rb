class AddChurchToUsers < ActiveRecord::Migration[8.0]
  def change
    # First add the column as nullable
    add_reference :users, :church, foreign_key: true
    add_column :users, :is_church_admin, :boolean, default: false, null: false
    
    # Create a default church for existing users if needed
    reversible do |dir|
      dir.up do
        if User.exists?
          default_church = Church.find_or_create_by!(name: 'Oikos Community Church') do |c|
            c.timezone = 'America/New_York'
            c.active = true
          end
          
          User.where(church_id: nil).update_all(church_id: default_church.id)
        end
      end
    end
    
    # Now make it non-nullable
    change_column_null :users, :church_id, false
    
    add_index :users, [:church_id, :is_church_admin]
  end
end
