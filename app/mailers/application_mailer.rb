class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@churchneeds.net")
  layout "mailer"
  
  before_action :check_email_suppression
  after_action :track_email_sent
  
  # Handle Postmark errors gracefully in staging (account pending approval)
  rescue_from Postmark::ApiInputError do |exception|
    if Rails.env.production? && ENV["APP_HOST"]&.include?("staging")
      # Log the error but don't fail the job in staging
      Rails.logger.warn "Postmark API Error (staging): #{exception.message}"
    else
      # Re-raise in production
      raise exception
    end
  end
  
  private
  
  def check_email_suppression
    # Get the recipient from the mail object
    recipient_email = params[:user]&.email_address || params[:email]
    return unless recipient_email
    
    user = User.find_by(email_address: recipient_email)
    return unless user
    
    if user.email_suppressed?
      Rails.logger.info "Email suppressed for #{recipient_email} - not sending"
      mail.perform_deliveries = false
    end
  end
  
  def track_email_sent
    # Track when we successfully sent an email
    return unless mail.perform_deliveries
    
    recipient_email = mail.to&.first
    return unless recipient_email
    
    user = User.find_by(email_address: recipient_email)
    return unless user
    
    user.update_column(:last_email_sent_at, Time.current)
  end
end
