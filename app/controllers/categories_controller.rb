class CategoriesController < ApplicationController
  before_action :require_admin
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = current_church.categories.order(:name)
  end

  def new
    @category = current_church.categories.new
  end

  def create
    @category = current_church.categories.new(category_params)
    
    if @category.save
      redirect_to categories_path, notice: "Category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.needs.exists?
      redirect_to categories_path, alert: "Cannot delete category with existing needs."
    else
      @category.destroy
      redirect_to categories_path, notice: "Category deleted successfully."
    end
  end

  private

  def set_category
    @category = current_church.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :color)
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user.admin?
  end
end
