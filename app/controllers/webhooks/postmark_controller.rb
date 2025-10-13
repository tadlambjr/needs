class Webhooks::PostmarkController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_postmark_signature
  
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
  
  def verify_postmark_signature
    # Postmark doesn't send a signature by default, but you can verify the IP
    # or use HTTP Basic Auth. For now, we'll just log the request.
    # In production, consider adding IP whitelist or basic auth.
    
    # Postmark IPs (as of 2025): 50.31.156.6, 50.31.156.77, 18.217.206.57
    # You can add IP verification here if needed
    
    Rails.logger.info "Postmark webhook received from IP: #{request.remote_ip}"
  end
end
