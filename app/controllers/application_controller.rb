# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :catch_exceptions
  helper_method :current_author

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: 'Действие вам недоступно.'
  end

protected
  def current_author
    current_user
  end

  def current_puffer_user
    current_user
  end

  def has_puffer_access?(namespace)
    current_puffer_user.try :admin?
  end

  def render_404
    redirect = Redirect.find_by_from request.fullpath
    if redirect
      redirect_to redirect.to, :status => 301
    else
      render 'pages/404', :status => 404
    end
  end

  def catch_exceptions
    yield
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
