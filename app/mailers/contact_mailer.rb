class ContactMailer < ApplicationMailer
  def contact_form(name, email, subject, message)
    @name = name
    @email = email
    @subject = subject || "Contact Form Submission"
    @message = message

    mail(
      to: "support@churchneeds.net",
      from: "noreply@churchneeds.net",
      reply_to: email,
      subject: "Contact Form: #{@subject}"
    )
  end
end
