class NeedsMailer < ApplicationMailer
  def new_need(user, need)
    @user = user
    @need = need
    @church = need.church
    
    mail(
      to: user.email_address,
      subject: "New Need Available: #{need.title}"
    )
  end
  
  def signup_confirmation(signup)
    @user = signup.user
    @need = signup.need
    @signup = signup
    @church = @need.church
    
    mail(
      to: @user.email_address,
      subject: "Signup Confirmed: #{@need.title}"
    )
  end
  
  def admin_approval_request(admin, need)
    @admin = admin
    @need = need
    @church = need.church
    @creator = need.creator
    
    mail(
      to: admin.email_address,
      subject: "New Need Requires Approval: #{need.title}"
    )
  end
  
  def need_cancelled(signup)
    @user = signup.user
    @need = signup.need
    @church = @need.church
    
    mail(
      to: @user.email_address,
      subject: "Need Cancelled: #{@need.title}"
    )
  end
  
  def reminder(signup)
    @user = signup.user
    @need = signup.need
    @church = @need.church
    
    mail(
      to: @user.email_address,
      subject: "Reminder: #{@need.title} - #{@need.start_date.strftime('%b %d')}"
    )
  end
end
