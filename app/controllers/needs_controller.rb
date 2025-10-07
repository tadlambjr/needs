class NeedsController < ApplicationController
  before_action :set_need, only: [:show, :edit, :update, :destroy, :signup, :cancel_signup, :approve, :reject, :complete]
  before_action :require_admin, only: [:approve, :reject, :destroy, :pending_approval]
  
  def index
    @needs = current_church.needs.member_visible.upcoming
                          .where(is_recurring: false)  # Exclude parent recurring needs, show only instances
                          .includes(:category, :creator, :need_signups)
    
    # Apply filters
    @needs = @needs.by_category(params[:category_id]) if params[:category_id].present?
    @needs = @needs.where('start_date >= ?', params[:start_date]) if params[:start_date].present?
    @needs = @needs.where('end_date <= ?', params[:end_date]) if params[:end_date].present?
    @needs = @needs.with_openings if params[:with_openings] == '1'
    
    # Search
    if params[:query].present?
      @needs = @needs.where('title LIKE ? OR description LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
    end
    
    @needs = @needs.order(:start_date).page(params[:page]).per(20) if defined?(Kaminari)
    @categories = current_church.categories.active.ordered
  end

  def show
    @signups = @need.need_signups.includes(:user).where(status: [:signed_up, :waitlist]).order(:signed_up_at)
    @user_signup = Current.user.need_signups.find_by(need: @need, status: [:signed_up, :waitlist]) if authenticated?
    @can_signup = authenticated? && @need.can_signup?(Current.user)
  end

  def new
    @need = current_church.needs.new(creator: Current.user)
    @categories = Current.user.admin? ? current_church.categories.active.ordered : current_church.categories.active.member_creatable.ordered
    @checklists = current_church.checklists.active.order(:name)
    @rooms = current_church.rooms.active.ordered
  end

  def create
    @need = current_church.needs.new(need_params)
    @need.creator = Current.user
    
    if @need.save
      # Create room bookings if any rooms were selected
      if params[:room_ids].present?
        params[:room_ids].reject(&:blank?).each do |room_id|
          @need.room_bookings.create(
            room_id: room_id,
            requested_by: Current.user,
            notes: params[:room_booking_notes]
          )
        end
      end
      
      redirect_to @need, notice: 'Need was successfully created.'
    else
      @categories = Current.user.admin? ? current_church.categories.active.ordered : current_church.categories.active.member_creatable.ordered
      @checklists = current_church.checklists.active.order(:name)
      @rooms = current_church.rooms.active.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_edit!
    @categories = Current.user.admin? ? current_church.categories.active.ordered : current_church.categories.active.member_creatable.ordered
    @checklists = current_church.checklists.active.order(:name)
    @rooms = current_church.rooms.active.ordered
  end

  def update
    authorize_edit!
    
    if @need.update(need_params)
      redirect_to @need, notice: 'Need was successfully updated.'
    else
      @categories = Current.user.admin? ? current_church.categories.active.ordered : current_church.categories.active.member_creatable.ordered
      @checklists = current_church.checklists.active.order(:name)
      @rooms = current_church.rooms.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    need_title = @need.title
    
    if @need.destroy
      respond_to do |format|
        format.html { 
          redirect_to root_path, notice: "#{need_title} was successfully deleted.", status: :see_other 
        }
        format.turbo_stream { 
          redirect_to root_path, notice: "#{need_title} was successfully deleted.", status: :see_other 
        }
      end
    else
      respond_to do |format|
        format.html { 
          redirect_to @need, alert: 'Unable to delete this need.', status: :see_other 
        }
        format.turbo_stream { 
          redirect_to @need, alert: 'Unable to delete this need.', status: :see_other 
        }
      end
    end
  end

  def signup
    if params[:specific_date].present?
      signup = @need.need_signups.new(user: Current.user, specific_date: params[:specific_date])
    else
      signup = @need.need_signups.new(user: Current.user)
    end
    
    if signup.save
      redirect_to @need, notice: 'You have successfully signed up for this need.'
    else
      redirect_to @need, alert: signup.errors.full_messages.join(', ')
    end
  end

  def cancel_signup
    signup = @need.need_signups.find_by(user: Current.user, status: [:signed_up, :waitlist])
    
    if signup&.cancel!(reason: params[:reason])
      redirect_to @need, notice: 'Your signup has been cancelled.'
    else
      redirect_to @need, alert: 'Unable to cancel signup.'
    end
  end

  def calendar
    # Allow navigation by month, default to current month
    if params[:start_date].present?
      base_date = Date.parse(params[:start_date])
    else
      base_date = Date.today
    end
    
    # Get the first and last day of the month
    month_start = base_date.beginning_of_month
    month_end = base_date.end_of_month
    
    # Extend to include full weeks (Sunday to Saturday)
    @calendar_start = month_start.beginning_of_week(:sunday)
    @calendar_end = month_end.end_of_week(:sunday)
    @current_month = base_date
    
    @calendar_needs = current_church.needs.member_visible
                          .where('start_date <= ? AND end_date >= ?', @calendar_end, @calendar_start)
                          .where(is_recurring: false)  # Exclude parent recurring needs, show only instances
                          .includes(:category, need_signups: :user)
    
    # Get user's signups for the calendar period
    @upcoming_signups = Current.user.need_signups.joins(:need)
                                   .where(status: [:signed_up, :waitlist])
                                   .where('needs.start_date <= ? AND needs.end_date >= ?', @calendar_end, @calendar_start)
                                   .includes(:need)
    
    # Get individual day signups for meal trains
    @day_signups = current_church.needs.joins(:need_signups)
                                  .where('need_signups.specific_date >= ? AND need_signups.specific_date <= ?', @calendar_start, @calendar_end)
                                  .where('need_signups.status' => [:signed_up, :waitlist, :completed])
                                  .where(allow_individual_day_signup: true)
                                  .includes(need_signups: [:user])
                                  .flat_map(&:need_signups)
                                  .select { |s| s.specific_date && s.specific_date >= @calendar_start && s.specific_date <= @calendar_end }
  end

  def my_needs
    @signups = Current.user.need_signups
                          .includes(need: :category)
                          .order('needs.start_date')
    @past_signups = Current.user.need_signups
                               .includes(need: :category)
                               .where(status: [:completed, :cancelled])
                               .order('needs.start_date DESC')
                               .limit(20)
  end

  def pending_approval
    @needs = current_church.needs.pending_approval.includes(:creator, :category).order(created_at: :desc)
    @pending_room_bookings = current_church.needs.joins(:room_bookings)
                                            .merge(RoomBooking.pending_approval)
                                            .includes(:creator, :category, room_bookings: [:room, :requested_by])
                                            .distinct
                                            .order('room_bookings.created_at DESC')
  end

  def approve
    if @need.update(status: :published, approved_at: Time.current, approved_by: Current.user)
      # TODO: Send notification to creator
      redirect_to pending_approval_needs_path, notice: 'Need approved and published.'
    else
      redirect_to pending_approval_needs_path, alert: 'Unable to approve need.'
    end
  end

  def reject
    if @need.update(status: :rejected)
      # TODO: Send notification to creator
      redirect_to pending_approval_needs_path, notice: 'Need rejected.'
    else
      redirect_to pending_approval_needs_path, alert: 'Unable to reject need.'
    end
  end

  def complete
    if @need.update(status: :completed, completed_at: Time.current, completed_by: Current.user)
      redirect_to @need, notice: 'Need marked as complete.'
    else
      redirect_to @need, alert: 'Unable to mark need as complete.'
    end
  end

  private

  def set_need
    @need = current_church.needs.includes(child_needs: [need_signups: :user]).find(params[:id])
  end

  def need_params
    params.require(:need).permit(
      :title, :description, :category_id, :start_date, :end_date, 
      :time_slot, :specific_time, :location, :volunteer_capacity,
      :allow_individual_day_signup, :is_recurring, :recurrence_pattern,
      :recurrence_start_day, :recurrence_end_day, :recurrence_end_date, :checklist_id,
      :content_type
    )
  end

  def require_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def authorize_edit!
    unless Current.user.admin? || (@need.creator == Current.user && @need.draft?)
      redirect_to @need, alert: 'You are not authorized to edit this need.'
    end
  end
end
