class ChecklistsController < ApplicationController
  before_action :require_admin
  before_action :set_checklist, only: [:show, :edit, :update, :destroy]

  def index
    @checklists = current_church.checklists.includes(:checklist_items).order(:name)
  end

  def show
  end

  def new
    @checklist = current_church.checklists.new
    3.times { @checklist.checklist_items.build }
  end

  def create
    @checklist = current_church.checklists.new(checklist_params)
    @checklist.created_by = Current.user
    
    if @checklist.save
      redirect_to checklists_path, notice: "Checklist created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @checklist.update(checklist_params)
      redirect_to checklists_path, notice: "Checklist updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @checklist.needs.exists?
      redirect_to checklists_path, alert: "Cannot delete checklist that is in use."
    else
      @checklist.destroy
      redirect_to checklists_path, notice: "Checklist deleted successfully."
    end
  end

  private

  def set_checklist
    @checklist = current_church.checklists.find(params[:id])
  end

  def checklist_params
    params.require(:checklist).permit(
      :name, 
      :description,
      :content_type,
      checklist_items_attributes: [:id, :description, :display_order, :_destroy]
    )
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
