class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :catch_exceptions
  helper_method :current_author

protected
  def current_author
    current_user
  end

  def check_author
    redirect_to new_user_session_path unless current_author
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
