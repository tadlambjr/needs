module ApplicationHelper
  def current_theme_class
    # Always return empty - theme is handled by JavaScript
    ''
  end
  
  def format_date(date)
    return '' if date.blank?
    date.strftime('%B %d, %Y')
  end
  
  def format_datetime(datetime)
    return '' if datetime.blank?
    datetime.strftime('%B %d, %Y at %I:%M %p')
  end
  
  def time_slot_label(time_slot, specific_time = nil)
    return '' if time_slot.blank?
    
    case time_slot.to_s
    when 'morning'
      'Morning (6am-12pm)'
    when 'afternoon'
      'Afternoon (12pm-6pm)'
    when 'evening'
      'Evening (6pm-10pm)'
    when 'all_day'
      'All Day'
    when 'specific_time'
      if specific_time.present?
        specific_time.strftime('%I:%M %p')
      else
        'Specific Time'
      end
    else
      time_slot.to_s.titleize
    end
  end
  
  def status_badge_class(status)
    case status.to_s
    when 'draft'
      'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
    when 'published'
      'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
    when 'full'
      'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
    when 'in_progress'
      'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300'
    when 'completed'
      'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300'
    when 'cancelled'
      'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    when 'rejected'
      'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    else
      'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
    end
  end
  
  def pending_approvals_count
    return 0 unless Current.user&.admin?
    @pending_approvals_count ||= Current.user.church.needs.pending_approval.count
  end
end
