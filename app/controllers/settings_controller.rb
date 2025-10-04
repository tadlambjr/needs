class SettingsController < ApplicationController
  def show
    @user = Current.user
    @notification_preferences = @user.notification_preferences.index_by(&:notification_type)
  end

  def update
    @user = Current.user
    
    if params[:notification_preferences].present?
      update_notification_preferences
    end
    
    if @user.update(settings_params)
      redirect_to settings_path, notice: "Settings updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(:theme_preference)
  end

  def update_notification_preferences
    params[:notification_preferences].each do |type, enabled|
      preference = Current.user.notification_preferences.find_or_initialize_by(notification_type: type)
      preference.update(enabled: enabled == "1")
    end
  end
end
