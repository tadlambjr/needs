class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:edit, :update, :transfer_ownership]

  def index
    @users = current_church.users.order(created_at: :desc).page(params[:page]).per(20)
    @church_owner = current_church.owner
  end

  def edit
    unless @user.can_be_edited_by?(Current.user)
      redirect_to admin_users_path, alert: "Only the church owner can edit the owner's account."
      return
    end
  end

  def update
    unless @user.can_be_edited_by?(Current.user)
      redirect_to admin_users_path, alert: "Only the church owner can edit the owner's account."
      return
    end
    
    # Prevent removing owner's admin status
    if @user.owner? && user_params[:role] == "member"
      redirect_to edit_admin_user_path(@user), alert: "Cannot remove admin status from church owner. Transfer ownership first."
      return
    end
    
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def transfer_ownership
    unless Current.user.owner?
      redirect_to admin_users_path, alert: "Only the church owner can transfer ownership."
      return
    end
    
    unless Current.user.can_transfer_ownership_to?(@user)
      redirect_to admin_users_path, alert: "Cannot transfer ownership to this user. They must be an admin in your church."
      return
    end
    
    ActiveRecord::Base.transaction do
      Current.user.update!(is_owner: false)
      @user.update!(is_owner: true, is_church_admin: true, role: :admin)
    end
    
    redirect_to admin_users_path, notice: "Ownership has been successfully transferred to #{@user.name}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_users_path, alert: "Failed to transfer ownership: #{e.message}"
  end

  private

  def set_user
    @user = current_church.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email_address, :phone, :role, :active)
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
