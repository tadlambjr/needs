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
  validate :only_one_owner_per_church, if: :is_owner?
  validate :owner_must_be_admin
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :verified, -> { where(email_verified: true) }
  scope :admins, -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }
  scope :owners, -> { where(is_owner: true) }
  
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
  
  def owner?
    is_owner?
  end
  
  def can_manage_church?
    owner?
  end
  
  def can_be_edited_by?(user)
    return false if owner? && !user.owner?
    user.admin?
  end
  
  def can_transfer_ownership_to?(target_user)
    return false unless owner?
    return false unless target_user.admin? || target_user.is_church_admin?
    return false if target_user.id == id
    target_user.church_id == church_id
  end
  
  private
  
  def only_one_owner_per_church
    if church && church.users.where(is_owner: true).where.not(id: id).exists?
      errors.add(:is_owner, "can only be assigned to one user per church")
    end
  end
  
  def owner_must_be_admin
    if is_owner? && !admin? && !is_church_admin?
      errors.add(:is_owner, "must be an admin")
    end
  end
end
