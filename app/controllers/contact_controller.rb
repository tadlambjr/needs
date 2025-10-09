class ContactController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  # Rate limiting - 3 submissions per hour per IP
  rate_limit to: 2, within: 1.hour, only: [ :create ], with: -> {
    flash[:alert] = "Too many contact form submissions. Please try again later."
    redirect_to new_contact_path
  }

  def new
    # Contact form - accessible to everyone
    # Set timestamp for bot detection
    @form_loaded_at = Time.current.to_i
  end

  def create
    # Honeypot check - if filled, it's a bot
    if params[:website].present?
      Rails.logger.warn "Contact form spam detected: honeypot filled"
      # Pretend it worked to not alert the bot
      flash[:notice] = "Thank you for contacting us! We'll get back to you as soon as possible."
      redirect_to root_path and return
    end

    # Time-based check - form submitted too quickly (less than 3 seconds)
    form_loaded_at = params[:form_loaded_at].to_i
    if form_loaded_at > 0 && (Time.current.to_i - form_loaded_at) < 3
      Rails.logger.warn "Contact form spam detected: submitted too quickly"
      flash[:notice] = "Thank you for contacting us! We'll get back to you as soon as possible."
      redirect_to root_path and return
    end

    @name = params[:name]
    @email = params[:email]
    @subject = params[:subject]
    @message = params[:message]

    # Validate required fields
    if @name.blank? || @email.blank? || @message.blank?
      flash.now[:alert] = "Please fill in all required fields."
      render :new and return
    end

    # Validate email format
    unless @email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:alert] = "Please enter a valid email address."
      render :new and return
    end

    # Send email to support
    ContactMailer.contact_form(@name, @email, @subject, @message).deliver_later

    # Show success message
    flash[:notice] = "Thank you for contacting us! We'll get back to you as soon as possible."
    redirect_to root_path
  end
end
