class NotificationService
  def self.notify_new_need(need)
    return unless need.published?
    
    # Get all users who should be notified
    users = need.church.users.active.where.not(id: need.creator_id)
    
    users.each do |user|
      # Check user's notification preferences
      pref = user.notification_preferences.find_by(notification_type: :new_need)
      
      # Create in-app notification if enabled (default: true)
      if pref.nil? || pref.in_app_enabled
        Notification.create!(
          user: user,
          notification_type: :new_need,
          title: "New Need: #{need.title}",
          message: "#{need.category.name} - #{need.start_date.strftime('%b %d')}",
          related_type: 'Need',
          related_id: need.id
        )
      end
      
      # Send email if enabled (default: true)
      if pref.nil? || pref.email_enabled
        NeedsMailer.new_need(user, need).deliver_later
      end
      
      # Send SMS if enabled and user has phone number
      if pref&.sms_enabled && user.phone.present?
        SmsService.send_message(
          to: user.phone,
          body: "New Need: #{need.title} - #{need.category.name} on #{need.start_date.strftime('%b %d')}. View details at #{need.church.name}."
        )
      end
    end
  end
  
  def self.notify_signup_confirmation(signup)
    user = signup.user
    need = signup.need
    
    pref = user.notification_preferences.find_by(notification_type: :signup_confirmation)
    
    # In-app notification
    if pref.nil? || pref.in_app_enabled
      Notification.create!(
        user: user,
        notification_type: :signup_confirmation,
        title: "Signup Confirmed",
        message: "You're signed up for: #{need.title}",
        related_type: 'Need',
        related_id: need.id
      )
    end
    
    # Email notification
    if pref.nil? || pref.email_enabled
      NeedsMailer.signup_confirmation(signup).deliver_later
    end
    
    # SMS notification
    if pref&.sms_enabled && user.phone.present?
      SmsService.send_message(
        to: user.phone,
        body: "Confirmed! You're signed up for: #{need.title} on #{need.start_date.strftime('%b %d')}."
      )
    end
  end
  
  def self.notify_admins_new_member_need(need)
    admins = need.church.users.where(role: :admin)
    
    admins.each do |admin|
      pref = admin.notification_preferences.find_by(notification_type: :approval_status)
      
      # In-app notification
      if pref.nil? || pref.in_app_enabled
        Notification.create!(
          user: admin,
          notification_type: :approval_status,
          title: "New Need Pending Approval",
          message: "#{need.creator.name} submitted: #{need.title}",
          related_type: 'Need',
          related_id: need.id
        )
      end
      
      # Email notification
      if pref.nil? || pref.email_enabled
        NeedsMailer.admin_approval_request(admin, need).deliver_later
      end
      
      # SMS notification
      if pref&.sms_enabled && admin.phone.present?
        SmsService.send_message(
          to: admin.phone,
          body: "New need pending approval: #{need.title} by #{need.creator.name}."
        )
      end
    end
  end
  
  def self.notify_need_cancelled(signup)
    user = signup.user
    need = signup.need
    
    pref = user.notification_preferences.find_by(notification_type: :cancellation)
    
    # In-app notification
    if pref.nil? || pref.in_app_enabled
      Notification.create!(
        user: user,
        notification_type: :cancellation,
        title: "Need Cancelled",
        message: "#{need.title} on #{need.start_date.strftime('%b %d')} has been cancelled",
        related_type: 'Need',
        related_id: need.id
      )
    end
    
    # Email notification
    if pref.nil? || pref.email_enabled
      NeedsMailer.need_cancelled(signup).deliver_later
    end
    
    # SMS notification
    if pref&.sms_enabled && user.phone.present?
      SmsService.send_message(
        to: user.phone,
        body: "Cancelled: #{need.title} on #{need.start_date.strftime('%b %d')} has been cancelled."
      )
    end
  end
end
