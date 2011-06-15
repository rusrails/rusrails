class PagesController < ApplicationController
  caches_action :index, :show
  
  def index
    @homepage = Page.matching("home") ||
        Page.create(:name => "Homepage", :url_match => "home")
    @categories = Category.enabled
  end

  def show
    if  @category = Category.matching(params[:category_url_match]) and
        @page = @category.pages.matching(params[:url_match])
      @categories = Category.enabled
      @pages = @category.pages.enabled
    else
      render "/public/404.html"
    end
  end

end
