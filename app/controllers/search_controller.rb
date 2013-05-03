class SearchController < ApplicationController
  def show
    @search = params[:search]
    @result = ThinkingSphinx.search @search
  end
end
