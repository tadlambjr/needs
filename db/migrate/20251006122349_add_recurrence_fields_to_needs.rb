class AddRecurrenceFieldsToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :recurrence_start_day, :integer
    add_column :needs, :recurrence_end_day, :integer
  end
end
