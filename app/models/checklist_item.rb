class ChecklistItem < ApplicationRecord
  # Associations
  belongs_to :checklist
  has_many :checklist_completions, dependent: :destroy
  
  # Validations
  validates :description, presence: true, length: { minimum: 3, maximum: 200 }
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :ordered, -> { order(:display_order) }
end
