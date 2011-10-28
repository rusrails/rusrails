class SaysController < ApplicationController
  before_filter :check_author

  def create
    @discussion = Discussion.enabled.find params[:discussion_id]
    @say = @discussion.says.build params[:say]
    @say.author = current_author
    if @say.save
      flash[:notice] = "Оставлено сообщение"
      @discussion.touch
    else
      flash[:alert] = "Произошли ошибки: " + @say.errors.full_messages * ", "
    end
    redirect_to @discussion
  end
end
