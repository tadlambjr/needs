class NotificationPreference < ApplicationRecord
  # Associations
  belongs_to :user
  
  # Enums
  enum :notification_type, { 
    new_need: 0, reminder: 1, signup_confirmation: 2, 
    cancellation: 3, need_modified: 4, approval_status: 5 
  }
  
  # Validations
  validates :notification_type, presence: true, uniqueness: { scope: :user_id }
end
