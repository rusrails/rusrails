class DiscussionsController < ApplicationController
  def index
    @discussions = Discussion.enabled
  end
end
