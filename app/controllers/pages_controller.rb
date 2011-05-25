class PagesController < ApplicationController
  def index
    @homepage = Page.matching("home") ||
        Page.create(:name => "Homepage", :url_match => "home")
  end

  def show
  end

end
