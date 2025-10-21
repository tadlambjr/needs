class Category < ApplicationRecord
  # Associations
  belongs_to :church
  has_many :needs, dependent: :restrict_with_error
  
  # Enums
  enum :category_type, {
    need: 0, event: 1
  }, default: :need
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :church_id, case_sensitive: false }, length: { minimum: 2, maximum: 50 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color code" }, allow_blank: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :member_creatable, -> { where(member_can_create: true) }
  scope :ordered, -> { order(:display_order, :name) }
  scope :for_needs, -> { where(category_type: :need) }
  scope :for_events, -> { where(category_type: :event) }
  
  # Class methods
  def self.default_categories
    [
      # Need categories
      { name: 'Cleaning', icon: 'broom', color: '#3B82F6', member_can_create: false, category_type: :need },
      { name: 'Lawn Care', icon: 'leaf', color: '#10B981', member_can_create: false, category_type: :need },
      { name: 'Yard Work', icon: 'tree', color: '#059669', member_can_create: false, category_type: :need },
      { name: 'Transportation', icon: 'car', color: '#6366F1', member_can_create: false, category_type: :need },
      { name: 'Meals', icon: 'utensils', color: '#F59E0B', member_can_create: false, category_type: :need },
      { name: 'Childcare', icon: 'baby', color: '#EC4899', member_can_create: false, category_type: :need },
      { name: 'Prayer Support', icon: 'hands-praying', color: '#8B5CF6', member_can_create: true, category_type: :need },
      { name: 'Technical Help', icon: 'laptop', color: '#06B6D4', member_can_create: true, category_type: :need },
      { name: 'Other', icon: 'question', color: '#6B7280', member_can_create: true, category_type: :need },
      # Event categories
      { name: 'Event', icon: 'calendar', color: '#F59E0B', member_can_create: false, category_type: :event },
      { name: 'Class', icon: 'book-open', color: '#8B5CF6', member_can_create: false, category_type: :event },
      { name: 'Meeting', icon: 'users', color: '#06B6D4', member_can_create: false, category_type: :event }
    ]
  end
end
