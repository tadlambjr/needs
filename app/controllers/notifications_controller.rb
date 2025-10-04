class NotificationsController < ApplicationController
  before_action :set_notification, only: [:mark_as_read]

  def index
    @notifications = Current.user.notifications
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(20)
    @unread_count = Current.user.notifications.unread.count
  end

  def mark_as_read
    @notification.mark_as_read!
    redirect_to notifications_path, notice: "Notification marked as read."
  end

  def mark_all_as_read
    Current.user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end

  private

  def set_notification
    @notification = Current.user.notifications.find(params[:id])
  end
end
