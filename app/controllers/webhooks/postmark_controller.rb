class Webhooks::PostmarkController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token
  before_action :authenticate_postmark
  
  # Postmark webhook endpoint
  # POST /webhooks/postmark
  def create
    case params[:RecordType]
    when "Bounce"
      handle_bounce
    when "SpamComplaint"
      handle_spam_complaint
    when "Delivery"
      handle_delivery
    else
      Rails.logger.info "Unhandled Postmark webhook type: #{params[:RecordType]}"
    end
    
    head :ok
  rescue StandardError => e
    Rails.logger.error "Postmark webhook error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    head :unprocessable_entity
  end
  
  private
  
  def handle_bounce
    email = params[:Email]
    bounce_type = params[:Type] # HardBounce, SoftBounce, etc.
    description = params[:Description]
    
    user = User.find_by(email_address: email)
    return unless user
    
    case bounce_type
    when "HardBounce"
      user.record_bounce!(type: :hard_bounce)
      Rails.logger.warn "Hard bounce for #{email}: #{description}"
    when "SoftBounce", "Transient"
      user.record_bounce!(type: :soft_bounce)
      Rails.logger.info "Soft bounce for #{email}: #{description}"
    when "SpamNotification"
      # Some bounces are actually spam blocks
      user.record_spam_complaint!
      Rails.logger.warn "Spam notification for #{email}: #{description}"
    else
      Rails.logger.info "Other bounce type '#{bounce_type}' for #{email}: #{description}"
    end
  end
  
  def handle_spam_complaint
    email = params[:Email]
    
    user = User.find_by(email_address: email)
    return unless user
    
    user.record_spam_complaint!
    Rails.logger.warn "Spam complaint from #{email}"
  end
  
  def handle_delivery
    email = params[:Recipient]
    
    user = User.find_by(email_address: email)
    return unless user
    
    user.update_column(:last_email_sent_at, Time.current)
  end
  
  def authenticate_postmark
    authenticate_or_request_with_http_basic do |username, password|
      expected_username = ENV['POSTMARK_WEBHOOK_USERNAME']
      expected_password = ENV['POSTMARK_WEBHOOK_PASSWORD']
      
      # Require both credentials to be set
      unless expected_username.present? && expected_password.present?
        Rails.logger.error "Postmark webhook credentials not configured"
        return false
      end
      
      # Use secure comparison to prevent timing attacks
      username_valid = ActiveSupport::SecurityUtils.secure_compare(username, expected_username)
      password_valid = ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
      
      if username_valid && password_valid
        Rails.logger.info "Postmark webhook authenticated successfully from IP: #{request.remote_ip}"
        true
      else
        Rails.logger.warn "Postmark webhook authentication failed from IP: #{request.remote_ip}"
        false
      end
    end
  end
end
