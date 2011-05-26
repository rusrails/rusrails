class PagesController < ApplicationController
  def index
    @homepage = Page.matching("home") ||
        Page.create(:name => "Homepage", :url_match => "home")
    @categories = Category.enabled
  end

  def show
  end

end
