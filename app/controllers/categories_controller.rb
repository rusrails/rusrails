class CategoriesController < ApplicationController
  def show
    @category = Category.matching(params[:url_match])
    render_404 unless @category
  end
end
