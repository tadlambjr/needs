class Admin::ReportsController < ApplicationController
  before_action :require_admin

  def index
    @date_range = params[:date_range] || '30'
    start_date = @date_range.to_i.days.ago
    
    @needs_by_category = current_church.needs.where('created_at >= ?', start_date)
                             .group(:category_id)
                             .count
    
    @signups_by_user = NeedSignup.joins(:need)
                                 .where(needs: { church_id: current_church.id })
                                 .where('need_signups.created_at >= ?', start_date)
                                 .group(:user_id)
                                 .count
    
    @needs_by_status = current_church.needs.where('created_at >= ?', start_date)
                           .group(:status)
                           .count
    
    @top_volunteers = current_church.users.joins(:need_signups)
                          .joins('INNER JOIN needs ON needs.id = need_signups.need_id')
                          .where(needs: { church_id: current_church.id })
                          .where('need_signups.created_at >= ?', start_date)
                          .group('users.id', 'users.name')
                          .count
                          .sort_by { |_, count| -count }
                          .first(10)
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
