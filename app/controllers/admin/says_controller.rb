# encoding: utf-8
class Admin::SaysController < Admin::IndexController
  def index
    @says = Say.ordered.includes(:discussion)
  end

  def edit
    @say = Say.find params[:id]
  end

  def update
    say = Say.find params[:id]
    say.enabled = params[:say][:enabled] if params[:say][:enabled]
    if say.update_attributes params[:say]
      flash[:notice] = "Обсуждение обновлено"
    else
      flash[:alert] = "Произошли ошибки: "+say.errors.full_messages*", "
    end
    redirect_to :back
  end

  def destroy
    say = Say.find params[:id]
    say.destroy
    redirect_to :back
  end
end
