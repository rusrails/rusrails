class SearchController < ApplicationController
  def show
    @search = params[:search]
    @result = Page.basic_search body: @search
  end
end
