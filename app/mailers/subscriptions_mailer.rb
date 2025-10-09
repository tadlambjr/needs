class SubscriptionsMailer < ApplicationMailer
  def subscription_created(subscription)
    @subscription = subscription
    @church = subscription.church
    @owner = @church.owner
    
    mail(
      to: @owner.email_address,
      subject: "Your ChurchNeeds.net Donation is Active"
    )
  end
  
  def payment_succeeded(subscription, amount_paid)
    @subscription = subscription
    @church = subscription.church
    @owner = @church.owner
    @amount = amount_paid
    @next_payment_date = subscription.next_billing_date
    
    mail(
      to: @owner.email_address,
      subject: "Payment Received - Thank You for Supporting ChurchNeeds.net"
    )
  end
  
  def payment_failed(subscription, amount_due, next_attempt_date)
    @subscription = subscription
    @church = subscription.church
    @owner = @church.owner
    @amount = amount_due
    @next_attempt_date = next_attempt_date
    
    mail(
      to: @owner.email_address,
      subject: "Payment Failed - Action Required for ChurchNeeds.net"
    )
  end
  
  def subscription_canceled(subscription)
    @subscription = subscription
    @church = subscription.church
    @owner = @church.owner
    @end_date = subscription.current_period_end
    
    mail(
      to: @owner.email_address,
      subject: "Your ChurchNeeds.net Subscription Has Been Canceled"
    )
  end
  
  def amount_updated(subscription, old_amount, new_amount)
    @subscription = subscription
    @church = subscription.church
    @owner = @church.owner
    @old_amount = old_amount / 100.0
    @new_amount = new_amount / 100.0
    @next_payment_date = subscription.next_billing_date
    
    mail(
      to: @owner.email_address,
      subject: "Your ChurchNeeds.net Donation Amount Has Been Updated"
    )
  end
end
