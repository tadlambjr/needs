class RoomBookingsController < ApplicationController
  before_action :set_room_booking, only: [:destroy, :approve, :reject]
  before_action :require_admin, only: [:approve, :reject]
  
  def create
    @need = current_church.needs.find(params[:room_booking][:need_id])
    
    # Create room bookings for each selected room
    room_ids = params[:room_booking][:room_ids].reject(&:blank?)
    
    room_ids.each do |room_id|
      room_booking = @need.room_bookings.new(
        room_id: room_id,
        requested_by: Current.user,
        notes: params[:room_booking][:notes]
      )
      room_booking.save
    end
    
    redirect_to @need, notice: 'Room booking request submitted successfully.'
  end
  
  def destroy
    authorize_cancel!
    @room_booking.destroy
    redirect_to @room_booking.need, notice: 'Room booking cancelled.'
  end
  
  def approve
    if @room_booking.approve!(Current.user)
      redirect_to pending_approval_needs_path, notice: 'Room booking approved.'
    else
      redirect_to pending_approval_needs_path, alert: 'Unable to approve room booking.'
    end
  end
  
  def reject
    if @room_booking.reject!(Current.user)
      redirect_to pending_approval_needs_path, notice: 'Room booking rejected.'
    else
      redirect_to pending_approval_needs_path, alert: 'Unable to reject room booking.'
    end
  end
  
  private
  
  def set_room_booking
    @room_booking = RoomBooking.joins(:need).where(needs: { church_id: current_church.id }).find(params[:id])
  end
  
  def authorize_cancel!
    unless Current.user.admin? || @room_booking.requested_by == Current.user
      redirect_to root_path, alert: 'Access denied.'
    end
  end
  
  def require_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
