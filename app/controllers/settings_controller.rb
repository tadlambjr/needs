class SettingsController < ApplicationController
  def show
    @user = Current.user
    @notification_preferences = @user.notification_preferences.index_by(&:notification_type)
  end

  def update
    @user = Current.user
    
    if params[:notification_preferences].present?
      update_notification_preferences
      redirect_to settings_path, notice: "Notification preferences updated successfully."
      return
    end
    
    if params[:user].present? && @user.update(settings_params)
      redirect_to settings_path, notice: "Settings updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.fetch(:user, {}).permit(:theme_preference)
  end

  def update_notification_preferences
    Notification.notification_types.keys.each do |type|
      preference = Current.user.notification_preferences.find_or_initialize_by(notification_type: type)
      type_params = params[:notification_preferences]&.[](type) || {}
      
      preference.update(
        email_enabled: type_params[:email_enabled] == "1",
        sms_enabled: type_params[:sms_enabled] == "1",
        in_app_enabled: type_params[:in_app_enabled] == "1"
      )
    end
  end
end
