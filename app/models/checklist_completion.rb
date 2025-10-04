class ChecklistCompletion < ApplicationRecord
  # Associations
  belongs_to :need_signup
  belongs_to :checklist_item
  
  # Callbacks
  before_save :set_completed_at
  
  private
  
  def set_completed_at
    self.completed_at = Time.current if completed? && completed_at.blank?
  end
end
