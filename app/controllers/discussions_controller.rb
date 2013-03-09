# encoding: utf-8
class DiscussionsController < ApplicationController
  before_filter :check_author, :only => [:new, :create]

  def index
    @discussions = Discussion.enabled.page(params[:page]).per(20)
  end

  def new
    @discussion = Discussion.new params[:discussion]
    @say = @discussion.says.build
  end

  def create
    @discussion = Discussion.new params[:discussion]
    @say = @discussion.says.first
    @discussion.author = current_author
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

  def show
    @discussion = Discussion.enabled.find(params[:id]).decorate
  end

  def preview
    @say = Say.new
    @say.renderer = 'md'
    @say.text = params[:data]
    render :inline => @say.decorate.html
  end
end
