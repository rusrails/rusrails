class CategoriesController < ApplicationController
  caches_action :show
  
  def show
    if @category = Category.matching(params[:url_match])
      @categories = Category.enabled
    else
      render "/public/404.html"
    end
  end
end
