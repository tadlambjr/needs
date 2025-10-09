class DonationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  allow_unauthenticated_access only: [:webhook]
  before_action :ensure_owner, only: [:new, :create, :success, :manage, :update_amount, :cancel, :reactivate]
  before_action :set_subscription, only: [:manage, :update_amount, :cancel, :reactivate]
  
  # Rate limiting to prevent abuse
  rate_limit to: 5, within: 1.minute, only: [:create], with: -> { redirect_to new_donation_path, alert: "Too many requests. Please try again in a moment." }
  rate_limit to: 10, within: 5.minutes, only: [:update_amount, :cancel, :reactivate], with: -> { redirect_to manage_donations_path, alert: "Too many requests. Please try again in a moment." }
  
  # GET /donations/new
  def new
    @subscription = current_church.active_subscription || current_church.subscriptions.build
    @default_amount = 25.00
  end
  
  # POST /donations
  def create
    amount_cents = (params[:amount].to_f * 100).to_i
    
    # Validate amount
    if amount_cents < 100 # Minimum $1
      flash[:alert] = "Donation amount must be at least $1"
      redirect_to new_donation_path and return
    end
    
    begin
      # Create or retrieve Stripe customer
      customer = get_or_create_stripe_customer
      
      # Create a checkout session
      session = Stripe::Checkout::Session.create(
        customer: customer.id,
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'ChurchNeeds.net Donation',
              description: 'Yearly donation to support hosting and development',
            },
            recurring: {
              interval: 'year'
            },
            unit_amount: amount_cents,
          },
          quantity: 1,
        }],
        mode: 'subscription',
        success_url: success_donations_url,
        cancel_url: new_donation_url,
        metadata: {
          church_id: current_church.id,
          amount_cents: amount_cents
        },
        subscription_data: {
          metadata: {
            church_id: current_church.id,
            statement_descriptor: 'ChurchNeeds.net'
          }
        }
      )
      
      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.message}"
      flash[:alert] = "There was an error processing your donation. Please try again."
      redirect_to new_donation_path
    end
  end
  
  # GET /donations/success
  def success
    @message = "Thank you for your donation! Your support helps keep ChurchNeeds.net running for churches everywhere."
  end
  
  # GET /donations/manage
  def manage
    unless @subscription
      flash[:notice] = "You don't have an active subscription."
      redirect_to new_donation_path and return
    end
    
    # Sync latest subscription data from Stripe
    sync_subscription_from_stripe
  end
  
  # PATCH /donations/update_amount
  def update_amount
    new_amount = params[:amount].to_f
    new_amount_cents = (new_amount * 100).to_i
    
    if new_amount_cents < 100
      flash[:alert] = "Donation amount must be at least $1"
      redirect_to manage_donations_path and return
    end
    
    old_amount_cents = @subscription.amount_cents
    
    if @subscription.update_amount(new_amount_cents)
      # Send confirmation email
      SubscriptionsMailer.amount_updated(@subscription, old_amount_cents, new_amount_cents).deliver_later
      
      flash[:notice] = "Your donation amount has been updated to $#{new_amount}."
      redirect_to manage_donations_path
    else
      flash[:alert] = "There was an error updating your donation amount. Please try again."
      redirect_to manage_donations_path
    end
  end
  
  # POST /donations/cancel
  def cancel
    if @subscription.cancel_subscription
      # Send cancellation confirmation email
      SubscriptionsMailer.subscription_canceled(@subscription).deliver_later
      
      flash[:notice] = "Your subscription will be canceled at the end of the current billing period."
      redirect_to manage_donations_path
    else
      flash[:alert] = "There was an error canceling your subscription. Please try again."
      redirect_to manage_donations_path
    end
  end
  
  # POST /donations/reactivate
  def reactivate
    if @subscription.reactivate_subscription
      flash[:notice] = "Your subscription has been reactivated."
      redirect_to manage_donations_path
    else
      flash[:alert] = "There was an error reactivating your subscription. Please try again."
      redirect_to manage_donations_path
    end
  end
  
  # POST /webhooks/stripe
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
    
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "JSON::ParserError in webhook: #{e.message}"
      head :bad_request and return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Stripe signature verification failed: #{e.message}"
      head :bad_request and return
    end
    
    # Handle the event
    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_succeeded'
      handle_invoice_payment_succeeded(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_payment_failed(event.data.object)
    end
    
    head :ok
  end
  
  private
  
  def ensure_owner
    unless Current.user.owner?
      flash[:alert] = "Only the account owner can manage donations."
      redirect_to root_path
    end
  end
  
  def set_subscription
    @subscription = current_church.active_subscription
  end
  
  def get_or_create_stripe_customer
    # Check if church already has a subscription with a customer ID
    existing_subscription = current_church.subscriptions.where.not(stripe_customer_id: nil).first
    
    if existing_subscription&.stripe_customer_id.present?
      begin
        return Stripe::Customer.retrieve(existing_subscription.stripe_customer_id)
      rescue Stripe::InvalidRequestError
        # Customer doesn't exist, create a new one
      end
    end
    
    # Create a new customer
    Stripe::Customer.create(
      email: Current.user.email_address,
      name: current_church.name,
      metadata: {
        church_id: current_church.id,
        user_id: Current.user.id
      }
    )
  end
  
  def handle_checkout_completed(session)
    church_id = session.metadata.church_id
    amount_cents = session.metadata.amount_cents
    
    # Retrieve the subscription from Stripe
    stripe_subscription = Stripe::Subscription.retrieve(session.subscription)
    
    # Find or create the subscription record to avoid duplicates
    subscription = Subscription.find_or_initialize_by(stripe_subscription_id: stripe_subscription.id)
    subscription.assign_attributes(
      church_id: church_id,
      stripe_customer_id: stripe_subscription.customer,
      status: :active,
      amount_cents: amount_cents,
      currency: 'usd',
      interval: 'year',
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
      cancel_at_period_end: false
    )
    
    if subscription.save
      # Send confirmation email
      SubscriptionsMailer.subscription_created(subscription).deliver_later
    else
      Rails.logger.error "Failed to save subscription: #{subscription.errors.full_messages.join(', ')}"
    end
  end
  
  def handle_subscription_updated(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription
    
    subscription.update(
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )
  end
  
  def handle_subscription_deleted(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription
    
    subscription.update(
      status: :canceled,
      canceled_at: Time.current
    )
  end
  
  def sync_subscription_from_stripe
    return unless @subscription&.stripe_subscription_id.present?
    
    begin
      stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
      
      @subscription.update(
        status: stripe_subscription.status,
        current_period_start: Time.at(stripe_subscription.current_period_start),
        current_period_end: Time.at(stripe_subscription.current_period_end),
        cancel_at_period_end: stripe_subscription.cancel_at_period_end
      )
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to sync subscription from Stripe: #{e.message}"
    end
  end
  
  def handle_invoice_payment_succeeded(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription
    
    # Update subscription status to active
    subscription.update(status: :active)
    
    # Send payment success email
    SubscriptionsMailer.payment_succeeded(subscription, invoice).deliver_later
    
    Rails.logger.info "Payment succeeded for subscription #{subscription.id}: #{invoice.amount_paid / 100.0}"
  end
  
  def handle_invoice_payment_failed(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription
    
    # Update subscription status
    subscription.update(status: :past_due)
    
    # Send payment failed email
    SubscriptionsMailer.payment_failed(subscription, invoice).deliver_later
    
    Rails.logger.error "Payment failed for subscription #{subscription.id}"
  end
end
