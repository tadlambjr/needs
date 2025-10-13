class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@churchneeds.net")
  layout "mailer"
  
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
end
