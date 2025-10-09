# Disable CSRF origin check in development to allow switching between localhost and 127.0.0.1
if Rails.env.development?
  Rails.application.config.action_controller.forgery_protection_origin_check = false
end
