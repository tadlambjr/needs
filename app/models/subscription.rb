class Subscription < ApplicationRecord
  belongs_to :church
  
  # Enums
  enum :status, {
    incomplete: 0,
    active: 1,
    past_due: 2,
    canceled: 3,
    unpaid: 4
  }, default: :incomplete
  
  # Validations
  validates :church, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :interval, presence: true, inclusion: { in: %w[month year] }
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true
  
  # Scopes
  scope :active_subscriptions, -> { where(status: :active) }
  scope :canceled_subscriptions, -> { where(status: :canceled) }
  
  # Instance methods
  def amount_in_dollars
    amount_cents / 100.0
  end
  
  def amount_in_dollars=(dollars)
    self.amount_cents = (dollars.to_f * 100).to_i
  end
  
  def display_amount
    "$#{amount_in_dollars}"
  end
  
  def display_interval
    interval == "year" ? "yearly" : "monthly"
  end
  
  def can_be_managed_by?(user)
    user.owner? && user.church_id == church_id
  end
  
  def next_billing_date
    current_period_end
  end
  
  def cancel_subscription
    return false unless stripe_subscription_id.present?
    
    begin
      Stripe::Subscription.update(
        stripe_subscription_id,
        cancel_at_period_end: true
      )
      
      update(cancel_at_period_end: true)
      true
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to cancel subscription: #{e.message}"
      false
    end
  end
  
  def reactivate_subscription
    return false unless stripe_subscription_id.present?
    return false unless cancel_at_period_end?
    
    begin
      Stripe::Subscription.update(
        stripe_subscription_id,
        cancel_at_period_end: false
      )
      
      update(cancel_at_period_end: false)
      true
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to reactivate subscription: #{e.message}"
      false
    end
  end
  
  def update_amount(new_amount_cents)
    return false unless stripe_subscription_id.present?
    
    begin
      # Get the subscription
      stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
      
      # Update the subscription item with the new price
      Stripe::Subscription.update(
        stripe_subscription_id,
        items: [{
          id: stripe_subscription.items.data[0].id,
          price_data: {
            currency: currency,
            product: stripe_subscription.items.data[0].price.product,
            recurring: { interval: interval },
            unit_amount: new_amount_cents
          }
        }],
        proration_behavior: 'none'
      )
      
      update(amount_cents: new_amount_cents)
      true
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to update subscription amount: #{e.message}"
      false
    end
  end
end
