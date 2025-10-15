class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset your password", to: user.email_address
  end

  def welcome_new_user(user)
    @user = user
    mail subject: "Welcome to #{user.church.name} - Set Your Password", to: user.email_address
  end
end
