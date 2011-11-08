class CategoriesController < ApplicationController
  def show
    if @category = Category.matching(params[:url_match])
      @categories = Category.enabled
    else
      render_404
    end
  end
end
