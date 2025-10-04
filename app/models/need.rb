class Need < ApplicationRecord
  # Associations
  belongs_to :church
  belongs_to :category
  belongs_to :creator, class_name: 'User'
  belongs_to :parent_need, class_name: 'Need', optional: true
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :completed_by, class_name: 'User', optional: true
  belongs_to :checklist, optional: true
  
  has_many :need_signups, dependent: :destroy
  has_many :volunteers, through: :need_signups, source: :user
  has_many :child_needs, class_name: 'Need', foreign_key: :parent_need_id, dependent: :destroy
  
  # Enums
  enum :status, { 
    draft: 0, published: 1, full: 2, in_progress: 3, completed: 4, cancelled: 5, rejected: 6 
  }, default: :draft
  
  enum :need_type, { 
    admin_created: 0, member_initiated: 1 
  }, default: :admin_created
  
  enum :time_slot, { 
    morning: 0, afternoon: 1, evening: 2, specific_time: 3, all_day: 4 
  }, allow_nil: true
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :volunteer_capacity, numericality: { only_integer: true, in: 1..20 }
  validate :end_date_after_start_date
  validate :specific_time_required_if_time_slot_is_specific
  
  # Scopes
  scope :published_needs, -> { where(status: :published) }
  scope :upcoming, -> { where('start_date >= ?', Date.today).order(:start_date) }
  scope :past, -> { where('end_date < ?', Date.today).order(start_date: :desc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :member_visible, -> { where(status: [:published, :full, :in_progress, :completed]) }
  scope :pending_approval, -> { where(status: :draft, need_type: :member_initiated) }
  scope :with_openings, -> { published_needs.where('volunteer_capacity > (SELECT COUNT(*) FROM need_signups WHERE need_signups.need_id = needs.id AND need_signups.status = 0)') }
  
  # Callbacks
  before_validation :set_need_type_based_on_creator
  after_create :notify_admins_if_member_initiated
  
  # Instance methods
  def available_spots
    volunteer_capacity - active_signups.count
  end
  
  def active_signups
    need_signups.where(status: [:signed_up, :waitlist])
  end
  
  def full?
    available_spots <= 0
  end
  
  def can_signup?(user)
    published? && !full? && !user.need_signups.exists?(need_id: id, status: [:signed_up, :waitlist])
  end
  
  def days_array
    return [] unless allow_individual_day_signup?
    (start_date..end_date).to_a
  end
  
  def signups_for_date(date)
    return need_signups.where(status: :signed_up) unless allow_individual_day_signup?
    need_signups.where(status: :signed_up, specific_date: date)
  end
  
  def available_for_date?(date)
    return false unless allow_individual_day_signup?
    signups_for_date(date).count < volunteer_capacity
  end
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
  
  def specific_time_required_if_time_slot_is_specific
    if specific_time? && specific_time.blank?
      errors.add(:specific_time, "is required when time slot is 'specific_time'")
    end
  end
  
  def set_need_type_based_on_creator
    self.need_type = creator&.admin? ? :admin_created : :member_initiated
  end
  
  def notify_admins_if_member_initiated
    return unless member_initiated?
    # TODO: Send notifications to admins
  end
end
