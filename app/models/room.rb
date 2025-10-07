class Room < ApplicationRecord
  belongs_to :church
  has_many :room_bookings, dependent: :destroy
  has_many :needs, through: :room_bookings
  
  validates :name, presence: true, uniqueness: { scope: :church_id }
  validates :capacity, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }
  
  def display_name
    capacity.present? ? "#{name} (Cap: #{capacity})" : name
  end
end
