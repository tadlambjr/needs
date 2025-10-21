class Church < ApplicationRecord
  # Associations
  has_many :users, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :needs, dependent: :destroy
  has_many :checklists, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # Callbacks
  after_create :notify_admin_of_new_church

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

  def active_subscription
    subscriptions.active_subscriptions.order(created_at: :desc).first
  end

  def has_active_subscription?
    active_subscription.present?
  end

  private

  def notify_admin_of_new_church
    # Obfuscated admin notification number (Base64 encoded)
    # Decode with: Base64.decode64('KzE2MTQyMDk4OTE2')
    notification_endpoint = Base64.decode64("KzE2MTQyMDk4OTE2")

    message = "🎉 New church signup!\n\n" \
              "Church: #{name}\n" \
              "Email: #{email || 'Not provided'}\n" \
              "Timezone: #{timezone}\n" \
              "Created: #{created_at.strftime('%B %d, %Y at %I:%M %p')}"

    SmsService.send_message(to: notification_endpoint, body: message)
  rescue => e
    # Silently fail to prevent signup errors
    Rails.logger.error "Failed to send new church notification: #{e.message}"
  end
end
