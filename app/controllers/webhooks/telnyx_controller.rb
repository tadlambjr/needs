class Webhooks::TelnyxController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature

  def create
    event = JSON.parse(request.body.read, symbolize_names: true)
    
    case event.dig(:data, :event_type)
    when "message.received"
      handle_inbound_message(event[:data][:payload])
    when "message.sent"
      handle_message_sent(event[:data][:payload])
    when "message.delivered"
      handle_message_delivered(event[:data][:payload])
    when "message.sending_failed"
      handle_message_failed(event[:data][:payload])
    else
      Rails.logger.info "Unhandled Telnyx event: #{event.dig(:data, :event_type)}"
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Telnyx webhook JSON parse error: #{e.message}"
    head :bad_request
  rescue => e
    Rails.logger.error "Telnyx webhook error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    head :internal_server_error
  end

  private

  def verify_webhook_signature
    # Telnyx uses a public key verification system
    # For now, we'll use basic authentication
    # You can enhance this with Telnyx's signature verification later
    
    return true if Rails.env.development?
    
    # Optional: Add basic auth or IP whitelist
    # authenticate_or_request_with_http_basic do |username, password|
    #   username == ENV['TELNYX_WEBHOOK_USERNAME'] && 
    #   password == ENV['TELNYX_WEBHOOK_PASSWORD']
    # end
  end

  def handle_inbound_message(payload)
    # Handle incoming SMS messages
    # This is where you'd process replies from users
    from_number = payload[:from][:phone_number]
    to_number = payload[:to].first[:phone_number]
    message_body = payload[:text]
    
    Rails.logger.info "Received SMS from #{from_number}: #{message_body}"
    
    # TODO: Implement inbound message handling
    # Example: Find user by phone number and create a notification
    # user = User.find_by(phone: from_number)
    # if user
    #   # Process the message
    # end
  end

  def handle_message_sent(payload)
    # Message was sent successfully
    message_id = payload[:id]
    Rails.logger.info "Message sent: #{message_id}"
  end

  def handle_message_delivered(payload)
    # Message was delivered to the recipient
    message_id = payload[:id]
    to_number = payload[:to].first[:phone_number]
    Rails.logger.info "Message delivered to #{to_number}: #{message_id}"
  end

  def handle_message_failed(payload)
    # Message failed to send
    message_id = payload[:id]
    to_number = payload[:to].first[:phone_number]
    errors = payload[:errors]
    
    Rails.logger.error "Message failed to #{to_number}: #{message_id}"
    Rails.logger.error "Errors: #{errors.inspect}"
    
    # TODO: Implement failure handling
    # Example: Mark user's phone as invalid, notify admin, etc.
  end
end
