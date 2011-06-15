# encoding: utf-8
class Admin::PagesController < Admin::IndexController
  after_filter :expire_content_cache, :only => [:create, :update, :destroy]
  
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
    @categories = Category.ordered
    @page = Page.find params[:id]
  end
  
  def update
    page = Page.find params[:id]
    if page.update_attributes params[:page]
      flash[:notice] = "Страница обновлена"
      redirect_to admin_pages_path
    else
      flash[:alert] = "Произошли ошибки: "+page.errors.full_messages*", "
      redirect_to edit_admin_page_path(page)
    end
  end
  
  def destroy
    page = Page.find params[:id]
    page.destroy
    redirect_to admin_pages_path
  end
end
