class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    @total_users = User.count
    @total_needs = Need.count
    @pending_needs = Need.pending_approval.count
    @active_needs = Need.published.count
    @total_signups = NeedSignup.count
    @recent_signups = NeedSignup.includes(:user, :need).order(created_at: :desc).limit(10)
    @recent_needs = Need.order(created_at: :desc).limit(10)
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
