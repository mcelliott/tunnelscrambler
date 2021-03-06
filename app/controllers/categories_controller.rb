class CategoriesController < ApplicationController
  include UndoDelete
  before_action :authenticate_user!
  load_and_authorize_resource
  respond_to :html, :js

  decorates_assigned :category
  decorates_assigned :categories, with: PaginatedCollectionDecorator

  # GET /categories
  # GET /categories.json
  def index
    @q = Category.all.order(name: :asc).search(params[:q])
    @categories = @q.result.page(params[:page])
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    flash[:notice] = 'Category was successfully created.' if @category.save
  end

  def update
    flash[:notice] = 'Category was successfully updated.' if @category.update(category_params)
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    if @category.destroy
      flash[:notice] = "Category was successfully deleted. #{undo_link(@category)}"
    else
      flash[:alert] = 'Failed to delete category.'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def category_params
    params.require(:category).permit(:name, :category_type)
  end
end
