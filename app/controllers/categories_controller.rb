class CategoriesController < ApplicationController
  def show
    if @category = Category.matching(params[:url_match])
      @categories = Category.enabled
    else
      redirect_to "/404.html"
    end
  end
end
