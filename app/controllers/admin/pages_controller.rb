# encoding: utf-8
class Admin::PagesController < Admin::IndexController
  def index
    @categories = Category.ordered
    category = Category.find_by_id params[:category_id]
    if category
      @pages = category.pages.ordered
    else
      @pages = Page.ordered
    end
  end
  
  def new
    @categories = Category.ordered
    @page = Page.new flash[:page]
  end
  
  def create
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end
