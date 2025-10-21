class MissionControlAccessController < ApplicationController
  def redirect_non_admin
    flash[:alert] = "You must be an admin to access this page."
    redirect_to root_path
  end
end
