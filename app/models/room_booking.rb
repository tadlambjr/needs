class RoomBooking < ApplicationRecord
  belongs_to :need
  belongs_to :room
  belongs_to :requested_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true
  
  enum :status, {
    pending: 0, approved: 1, rejected: 2
  }, default: :pending
  
  validates :need_id, uniqueness: { scope: :room_id }
  
  scope :pending_approval, -> { where(status: :pending) }
  scope :approved_bookings, -> { where(status: :approved) }
  
  def approve!(admin)
    update(status: :approved, approved_by: admin, approved_at: Time.current)
  end
  
  def reject!(admin)
    update(status: :rejected, approved_by: admin, approved_at: Time.current)
  end
end
