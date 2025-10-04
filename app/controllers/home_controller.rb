class HomeController < ApplicationController
  allow_unauthenticated_access only: [:index]
  
  def index
    if authenticated?
      @upcoming_signups = Current.user.need_signups.joins(:need)
                                     .where(status: [:signed_up, :waitlist])
                                     .where('needs.start_date >= ?', Date.today)
                                     .where('needs.start_date <= ?', Date.today + 7.days)
                                     .includes(:need => :category)
                                     .order('needs.start_date')
      
      @upcoming_needs = Need.member_visible
                           .upcoming
                           .where('start_date <= ?', Date.today + 42.days)
                           .includes(:category, :creator)
                           .limit(20)
      
      @categories = Category.active.ordered
      @unread_notifications_count = Current.user.notifications.unread.count
      
      # Calendar data - 6 weeks starting from today
      @calendar_start = Date.today.beginning_of_week
      @calendar_end = @calendar_start + 6.weeks
      @calendar_needs = Need.member_visible
                           .where('start_date <= ? AND end_date >= ?', @calendar_end, @calendar_start)
                           .includes(:category, :need_signups)
                           .order(:start_date)
    end
  end
end
