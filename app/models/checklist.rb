class Checklist < ApplicationRecord
  # Associations
  belongs_to :church
  belongs_to :created_by, class_name: 'User'
  has_many :checklist_items, dependent: :destroy
  has_many :needs, dependent: :nullify
  
  # Enums
  enum :content_type, {
    need: 0, event: 1
  }, default: :need
  
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_needs, -> { where(content_type: :need) }
  scope :for_events, -> { where(content_type: :event) }
  
  accepts_nested_attributes_for :checklist_items, allow_destroy: true
end
