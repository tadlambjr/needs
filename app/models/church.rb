class Church < ApplicationRecord
  # Associations
  has_many :users, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :needs, dependent: :destroy
  has_many :checklists, dependent: :destroy
  has_many :rooms, dependent: :destroy
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :timezone, presence: true
  
  # Scopes
  scope :active, -> { where(active: true) }
  
  # Instance methods
  def church_admins
    users.where(is_church_admin: true)
  end
  
  def members
    users.where(is_church_admin: false)
  end
  
  def owner
    users.find_by(is_owner: true)
  end
  
  def has_owner?
    owner.present?
  end
end
