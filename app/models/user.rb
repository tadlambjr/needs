class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  
  # Associations
  belongs_to :church
  has_many :needs, foreign_key: :creator_id, dependent: :destroy
  has_many :need_signups, dependent: :destroy
  has_many :volunteered_needs, through: :need_signups, source: :need
  has_many :notifications, dependent: :destroy
  has_many :notification_preferences, dependent: :destroy
  
  # Enums
  enum :role, { member: 0, admin: 1 }, default: :member
  enum :theme_preference, { system: 0, light: 1, dark: 2 }, default: :system

  # Normalizations
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email_address, presence: true, uniqueness: { scope: :church_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :church, presence: true
  validates :phone, length: { maximum: 20 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :timezone, presence: true
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :verified, -> { where(email_verified: true) }
  scope :admins, -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }
  
  # Instance methods
  def admin?
    role == "admin" || is_church_admin?
  end
  
  def church_admin?
    is_church_admin?
  end
  
  def member?
    role == "member" && !is_church_admin?
  end
  
  def can_create_needs_in_category?(category)
    admin? || category.member_can_create?
  end
end
