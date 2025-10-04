class Category < ApplicationRecord
  # Associations
  belongs_to :church
  has_many :needs, dependent: :restrict_with_error
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :church_id, case_sensitive: false }, length: { minimum: 2, maximum: 50 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color code" }, allow_blank: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :member_creatable, -> { where(member_can_create: true) }
  scope :ordered, -> { order(:display_order, :name) }
  
  # Class methods
  def self.default_categories
    [
      { name: 'Cleaning', icon: 'broom', color: '#3B82F6', member_can_create: false },
      { name: 'Lawn Care', icon: 'leaf', color: '#10B981', member_can_create: false },
      { name: 'Yard Work', icon: 'tree', color: '#059669', member_can_create: false },
      { name: 'Transportation', icon: 'car', color: '#6366F1', member_can_create: false },
      { name: 'Meals', icon: 'utensils', color: '#F59E0B', member_can_create: false },
      { name: 'Childcare', icon: 'baby', color: '#EC4899', member_can_create: false },
      { name: 'Prayer Support', icon: 'hands-praying', color: '#8B5CF6', member_can_create: true },
      { name: 'Technical Help', icon: 'laptop', color: '#06B6D4', member_can_create: true },
      { name: 'Other', icon: 'question', color: '#6B7280', member_can_create: true }
    ]
  end
end
