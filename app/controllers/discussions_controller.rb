class DiscussionsController < ApplicationController
  def index
    @discussions = Discussion.enabled
  end

  def new
  end

  def create
  end

  def show
    @discussion = Discussion.enabled.find params[:id]
  end
end
