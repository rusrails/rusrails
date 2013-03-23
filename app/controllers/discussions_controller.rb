# encoding: utf-8
class DiscussionsController < ApplicationController
  load_and_authorize_resource

  def index
    @discussions = @discussions.ordered.page(params[:page]).per(20)
  end

  def new
    @say = @discussion.says.build
  end

  def create
    @say = @discussion.says.first
    @say.author = current_author
    @say.renderer = 'md'

    if @discussion.save
      flash[:notice] = "Начато новое обсуждение"
      redirect_to @discussion
    else
      flash[:alert] = "Произошли ошибки: " + @discussion.errors.full_messages * ", "
      render :new
    end
  end
end
