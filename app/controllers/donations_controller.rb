class DonationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  allow_unauthenticated_access only: [:webhook]
  before_action :ensure_owner, only: [:new, :create, :manage, :update_amount, :cancel, :reactivate]
  before_action :set_subscription, only: [:manage, :update_amount, :cancel, :reactivate]
  
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
        success_url: donations_success_url,
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
  end
  
  # PATCH /donations/update_amount
  def update_amount
    new_amount = params[:amount].to_f
    new_amount_cents = (new_amount * 100).to_i
    
    if new_amount_cents < 100
      flash[:alert] = "Donation amount must be at least $1"
      redirect_to manage_donations_path and return
    end
    
    if @subscription.update_amount(new_amount_cents)
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
    subscription = Stripe::Subscription.retrieve(session.subscription)
    
    # Create or update the subscription record
    Subscription.create!(
      church_id: church_id,
      stripe_subscription_id: subscription.id,
      stripe_customer_id: subscription.customer,
      status: :active,
      amount_cents: amount_cents,
      currency: 'usd',
      interval: 'year',
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end: Time.at(subscription.current_period_end),
      cancel_at_period_end: false
    )
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
end
