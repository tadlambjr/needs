class ProfilesController < ApplicationController
  def show
    @user = Current.user
    @upcoming_signups = @user.need_signups
                             .includes(need: :category)
                             .upcoming
                             .order('needs.start_date ASC')
                             .limit(5)
    @completed_signups = @user.need_signups
                              .includes(need: :category)
                              .completed
                              .order('needs.start_date DESC')
                              .limit(10)
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email_address, :phone, :bio)
  end
end
