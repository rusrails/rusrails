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
    page = Page.new params[:page]
    if page.save
      flash[:notice] = "страница создана"
      redirect_to admin_pages_path
    else
      flash[:alert] = "Произошли ошибки: "+page.errors.full_messages*", "
      flash[:page] = params[:page]
      redirect_to new_admin_page_path
    end
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end
