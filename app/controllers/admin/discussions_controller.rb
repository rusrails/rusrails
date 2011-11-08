# encoding: utf-8
class Admin::DiscussionsController < Admin::IndexController
  def index
    @discussions = Discussion.ordered
  end

  def edit
    @discussion = Discussion.find params[:id]
  end

  def update
    discussion = Discussion.find params[:id]
    discussion.enabled = params[:discussion][:enabled] if params[:discussion][:enabled]
    if discussion.update_attributes params[:discussion]
      flash[:notice] = "Обсуждение обновлено"
    else
      flash[:alert] = "Произошли ошибки: "+discussion.errors.full_messages*", "
    end
    redirect_to :back
  end

  def destroy
    discussion = Discussion.find params[:id]
    discussion.destroy
    redirect_to :back
  end
end
