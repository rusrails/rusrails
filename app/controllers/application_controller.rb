# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  around_action :catch_exceptions

protected
  def render_404
    redirect = Redirect.find_by_from request.fullpath
    if redirect
      redirect_to redirect.to, status: 301
    else
      render 'pages/404', status: 404
    end
  end

  def catch_exceptions
    yield
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
