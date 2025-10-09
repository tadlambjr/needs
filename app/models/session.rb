class Session < ApplicationRecord
  belongs_to :user
  
  # Generate a secure restore token for session recovery after Stripe checkout
  def generate_restore_token!
    self.restore_token = SecureRandom.urlsafe_base64(32)
    save!
    restore_token
  end
  
  # Find session by restore token and clear it after use
  def self.find_by_restore_token(token)
    return nil if token.blank?
    
    session = find_by(restore_token: token)
    # Clear the token after use for security
    session&.update(restore_token: nil)
    session
  end
end
