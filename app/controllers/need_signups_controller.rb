class NeedSignupsController < ApplicationController
  before_action :set_need_signup, only: [:destroy, :checklist, :mark_complete]

  def create
    @need = Need.find(params[:need_signup][:need_id])
    @need_signup = @need.need_signups.build(need_signup_params)
    @need_signup.user = Current.user
    
    if @need_signup.save
      redirect_to @need, notice: "Successfully signed up for this need."
    else
      redirect_to @need, alert: @need_signup.errors.full_messages.join(", ")
    end
  end

  def destroy
    if @need_signup.can_cancel?
      @need_signup.cancel!
      redirect_to @need_signup.need, notice: "Signup cancelled successfully."
    else
      redirect_to @need_signup.need, alert: "Cannot cancel signup within 24 hours of start time."
    end
  end

  def checklist
    @need = @need_signup.need
    @checklist = @need.checklist
    
    if @checklist.nil?
      redirect_to @need, alert: "This need does not have a checklist."
      return
    end
    
    @checklist_items = @checklist.checklist_items.ordered
  end

  def mark_complete
    if @need_signup.update(status: :completed, completed_at: Time.current)
      redirect_to @need_signup.need, notice: "Great job! You've completed this need."
    else
      redirect_to @need_signup.need, alert: "Unable to mark as complete."
    end
  end

  private

  def set_need_signup
    @need_signup = Current.user.need_signups.find(params[:id])
  end

  def need_signup_params
    params.require(:need_signup).permit(:need_id, :notes)
  end
end
