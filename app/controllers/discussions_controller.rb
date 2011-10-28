class DiscussionsController < ApplicationController
  before_filter :check_author, :only => [:new, :create]

  def index
    @discussions = Discussion.enabled
    @categories = Category.enabled
  end

  def new
    @discussion = Discussion.new
    @say = @discussion.says.build
  end

  def create
    @discussion = Discussion.new params[:discussion]
    @say = @discussion.says.first
    @discussion.author = current_author
    @say.author = current_author

    if @discussion.save
      flash[:notice] = "Начато новое обсуждение"
      redirect_to @discussion
    else
      flash[:alert] = "Произошли ошибки: " + @discussion.errors.full_messages * ", "
      render :new
    end
  end

  def show
    @discussion = Discussion.enabled.find params[:id]
    @categories = Category.enabled
  end
end
