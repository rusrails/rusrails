# encoding: utf-8
class Admin::CategoriesController < Admin::IndexController
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
      redirect_to admin_categories_path
    else
      flash[:alert] = "Произошли ошибки: "+category.errors.full_messages*", "
      flash[:category] = params[:category]
      redirect_to new_admin_category_path
    end
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end
