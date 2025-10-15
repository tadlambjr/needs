class SmsService
  class << self
    # Send an SMS message to a single recipient
    def send_message(to:, body:, from: nil)
      return false unless sms_enabled?
      return false if to.blank? || body.blank?

      from_number = from || default_from_number
      
      begin
        response = telnyx_client.messages.create(
          from: from_number,
          to: normalize_phone_number(to),
          text: body,
          messaging_profile_id: ENV['TELNYX_MESSAGING_PROFILE_ID']
        )
        
        Rails.logger.info "SMS sent to #{to}: #{response.data.id}"
        true
      rescue => e
        Rails.logger.error "SMS sending error: #{e.class} - #{e.message}"
        false
      end
    end

    # Send SMS to multiple recipients
    def send_bulk(recipients:, body:, from: nil)
      return [] unless sms_enabled?
      
      results = []
      recipients.each do |recipient|
        success = send_message(to: recipient, body: body, from: from)
        results << { phone: recipient, success: success }
      end
      results
    end

    # Normalize phone number to E.164 format
    def normalize_phone_number(phone)
      # Remove all non-digit characters
      digits = phone.to_s.gsub(/\D/, '')
      
      # Add +1 for US numbers if not present
      if digits.length == 10
        "+1#{digits}"
      elsif digits.length == 11 && digits.start_with?('1')
        "+#{digits}"
      else
        "+#{digits}"
      end
    end

    # Validate phone number format
    def valid_phone_number?(phone)
      return false if phone.blank?
      normalized = normalize_phone_number(phone)
      # Basic validation: starts with + and has 11-15 digits
      normalized.match?(/^\+\d{11,15}$/)
    end

    private

    def telnyx_client
      @telnyx_client ||= Telnyx::Client.new(
        api_key: ENV['TELNYX_API_KEY']
      )
    end

    def sms_enabled?
      ENV['TELNYX_API_KEY'].present? && 
      ENV['TELNYX_MESSAGING_PROFILE_ID'].present? &&
      default_from_number.present?
    end

    def default_from_number
      ENV['TELNYX_PHONE_NUMBER']
    end
  end
end
