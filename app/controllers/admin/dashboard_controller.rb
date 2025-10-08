class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    @total_users = current_church.users.count
    @total_needs = current_church.needs.count
    @pending_needs = current_church.needs.pending_approval.count
    @active_needs = current_church.needs.published.count
    @total_signups = NeedSignup.joins(:need).where(needs: { church_id: current_church.id }).count
    @recent_signups = NeedSignup.joins(:need).where(needs: { church_id: current_church.id }).includes(:user, :need).order(created_at: :desc).limit(10)
    @recent_needs = current_church.needs.order(created_at: :desc).limit(10)
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
