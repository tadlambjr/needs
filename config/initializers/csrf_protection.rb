# Configure CSRF protection
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Enable per-form CSRF tokens in production for better security
if Rails.env.production?
  Rails.application.config.action_controller.per_form_csrf_tokens = true
end
