class PagesController < ApplicationController
  def index
    @homepage = Page.matching("home").decorate
  end

  def show
    if  @category = Category.matching(params[:category_url_match]) and
        @page = @category.pages.matching(params[:url_match]).decorate
      @pages = @category.pages.enabled
    else
      render_404
    end
  end

  def map
  end

end
