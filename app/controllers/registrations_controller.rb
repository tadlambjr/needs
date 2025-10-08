class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  
  def new
    @user = User.new
    @churches = Church.active.order(:name)
  end
  
  def create
    @churches = Church.active.order(:name)
    
    if params[:user][:church_option] == "new"
      # Creating a new church
      @church = Church.new(church_params)
      @user = @church.users.build(user_params)
      @user.is_church_admin = true
      @user.role = :admin
      @user.is_owner = true
      
      if @church.save
        start_new_session_for @user
        redirect_to root_path, notice: "Welcome! Your church account has been created."
      else
        render :new, status: :unprocessable_entity
      end
    else
      # Joining existing church
      @church = Church.find(params[:user][:church_id])
      @user = @church.users.build(user_params)
      
      if @user.save
        start_new_session_for @user
        redirect_to root_path, notice: "Welcome! Your account has been created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotFound
    @user = User.new(user_params)
    @user.errors.add(:church, "must be selected")
    render :new, status: :unprocessable_entity
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :phone)
  end
  
  def church_params
    params.require(:user).permit(:church_name, :church_address, :church_city, :church_state, 
                                  :church_zip, :church_phone, :church_email, :church_timezone)
          .transform_keys { |key| key.to_s.sub('church_', '') }
  end
end
