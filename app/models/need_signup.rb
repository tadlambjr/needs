class NeedSignup < ApplicationRecord
  # Associations
  belongs_to :need
  belongs_to :user
  has_many :checklist_completions, dependent: :destroy
  
  # Enums
  enum :status, { 
    signed_up: 0, waitlist: 1, cancelled: 2, completed: 3 
  }, default: :signed_up
  
  # Validations
  validates :signed_up_at, presence: true
  validate :cannot_signup_for_past_need
  validate :cannot_signup_if_already_signed_up
  
  # Scopes
  scope :active, -> { where(status: [:signed_up, :waitlist]) }
  scope :for_date, ->(date) { where(specific_date: date) }
  scope :upcoming, -> { 
    joins(:need).where('needs.start_date >= ?', Date.today).where(status: [:signed_up, :waitlist]) 
  }
  scope :completed, -> { where(status: :completed) }
  
  # Callbacks
  before_validation :set_signed_up_at, on: :create
  after_create :send_confirmation_notification
  after_update :send_cancellation_notification, if: :saved_change_to_status?
  
  # Instance methods
  def can_cancel?
    signed_up? && (need.start_date - Date.today).to_i > 1
  end
  
  def cancel!(reason: nil)
    return false unless can_cancel?
    update(status: :cancelled, cancelled_at: Time.current, cancellation_reason: reason)
  end
  
  private
  
  def set_signed_up_at
    self.signed_up_at ||= Time.current
  end
  
  def cannot_signup_for_past_need
    errors.add(:need, "cannot sign up for past needs") if need&.start_date && need.start_date < Date.today
  end
  
  def cannot_signup_if_already_signed_up
    return if specific_date.present? # Allow multiple signups for meal trains
    if user && need && NeedSignup.where(user: user, need: need, status: [:signed_up, :waitlist]).where.not(id: id).exists?
      errors.add(:base, "You have already signed up for this need")
    end
  end
  
  def send_confirmation_notification
    ::NotificationService.notify_signup_confirmation(self)
  end
  
  def send_cancellation_notification
    return unless cancelled?
    ::NotificationService.notify_need_cancelled(self)
  end
end
