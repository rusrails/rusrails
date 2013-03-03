class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource
  around_filter :catch_exceptions
  helper_method :current_author

protected
  def layout_by_resource
    devise_controller? && resource_class == Admin ? "admin" : "application"
  end

  def current_author
    current_user || current_admin
  end

  def check_author
    redirect_to new_user_session_path unless current_author
  end

  def current_puffer_user
    current_admin
  end

  def render_404
    redirect = Redirect.find_by_from request.fullpath
    if redirect
      redirect_to redirect.to, :status => 301
    else
      render 'pages/404', :status => 404
    end
  end

private
  def after_sign_out_path_for resource
    resource == Admin ? admin_root_path : root_path
  end

  def catch_exceptions
    yield
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
