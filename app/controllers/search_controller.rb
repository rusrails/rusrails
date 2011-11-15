class SearchController < ApplicationController
  def show
    @search = params[:search]
    @result = ThinkingSphinx.search @search, :with => {:enabled => true}
  end
end
