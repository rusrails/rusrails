class PagesController < ApplicationController
  def index
    @homepage = Page.matching("home").decorate
  end

  def show
    @page = Page.matching(params[:url_match])
    if @page
      @page = @page.decorate
    else
      render_404
    end
  end

  def map
  end

end
