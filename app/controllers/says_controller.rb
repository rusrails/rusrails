# encoding: utf-8
class SaysController < ApplicationController
  load_and_authorize_resource :discussion
  load_and_authorize_resource :through => :discussion, :shallow => true, :new => :preview

  def index
    @discussion = @discussion.decorate
    @says = @says.decorate
  end

  def create
    @say.renderer = 'md'
    if @say.save
      flash[:notice] = "Оставлено сообщение"
    else
      flash[:alert] = "Произошли ошибки: " + @say.errors.full_messages * ", "
    end
    redirect_to [@discussion, :says]
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def preview
    @say.renderer = 'md'
    @say.text = params[:data]
    render :inline => @say.decorate.html
  end
end
