# encoding: utf-8
class Admin::CategoriesController < Admin::IndexController
  after_filter :expire_content_cache, :only => [:create, :update, :destroy]
  
  def index
    @categories = Category.ordered
  end
  
  def new
    @category = Category.new flash[:category]
  end
  
  def create
    category = Category.new params[:category]
    if category.save
      flash[:notice] = "Категория создана"
      path = params[:apply] ? edit_admin_category_path(category) : admin_categories_path
      redirect_to path
    else
      flash[:alert] = "Произошли ошибки: "+category.errors.full_messages*", "
      flash[:category] = params[:category]
      redirect_to new_admin_category_path
    end
  end
  
  def edit
    @category = Category.find params[:id]
  end
  
  def update
    category = Category.find params[:id]
    if category.update_attributes params[:category]
      flash[:notice] = "Категория обновлена"
      path = params[:apply] ? edit_admin_category_path(category) : admin_categories_path
      redirect_to path
    else
      flash[:alert] = "Произошли ошибки: "+category.errors.full_messages*", "
      redirect_to edit_admin_category_path(category)
    end
  end
  
  def destroy
    category = Category.find params[:id]
    category.destroy
    redirect_to admin_categories_path
  end
end
