class ChecklistItemsController < ApplicationController
  before_action :require_admin
  before_action :set_checklist

  def create
    @checklist_item = @checklist.checklist_items.build(checklist_item_params)
    
    if @checklist_item.save
      redirect_to checklist_path(@checklist), notice: "Item added successfully."
    else
      redirect_to checklist_path(@checklist), alert: "Failed to add item."
    end
  end

  def update
    @checklist_item = @checklist.checklist_items.find(params[:id])
    
    if @checklist_item.update(checklist_item_params)
      redirect_to checklist_path(@checklist), notice: "Item updated successfully."
    else
      redirect_to checklist_path(@checklist), alert: "Failed to update item."
    end
  end

  def destroy
    @checklist_item = @checklist.checklist_items.find(params[:id])
    @checklist_item.destroy
    redirect_to checklist_path(@checklist), notice: "Item removed successfully."
  end

  private

  def set_checklist
    @checklist = Checklist.find(params[:checklist_id])
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:description, :display_order)
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
