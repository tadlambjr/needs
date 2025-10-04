class Notification < ApplicationRecord
  # Associations
  belongs_to :user
  
  # Enums
  enum :notification_type, { 
    new_need: 0, reminder: 1, signup_confirmation: 2, 
    cancellation: 3, need_modified: 4, approval_status: 5 
  }
  
  # Validations
  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true
  
  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read_notifications, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc).limit(50) }
  
  # Instance methods
  def mark_as_read!
    update(read: true, read_at: Time.current)
  end
end
