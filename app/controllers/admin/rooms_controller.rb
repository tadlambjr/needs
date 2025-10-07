class Admin::RoomsController < ApplicationController
  before_action :require_admin
  before_action :set_room, only: [:edit, :update, :destroy]
  
  def index
    @rooms = current_church.rooms.ordered
  end

  def new
    @room = current_church.rooms.new
  end

  def create
    @room = current_church.rooms.new(room_params)
    
    if @room.save
      redirect_to admin_rooms_path, notice: 'Room was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @room.update(room_params)
      redirect_to admin_rooms_path, notice: 'Room was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy
    redirect_to admin_rooms_path, notice: 'Room was successfully deleted.'
  end
  
  private
  
  def set_room
    @room = current_church.rooms.find(params[:id])
  end
  
  def room_params
    params.require(:room).permit(:name, :description, :capacity, :location, :active)
  end
  
  def require_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
