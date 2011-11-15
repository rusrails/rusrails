class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource
  around_filter :catch_exceptions
  helper_method :current_author, :page_cache_key

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

  def method_missing method_name, *args
    render_404
  end

  def render_404
    render 'pages/404', :status => 404
  end

  def page_cache_key
    if @page
      "page_#{@page.id}"
    elsif @category
      "category_#{@category.id}"
    else
      ""
    end
  end

private
  def after_sign_out_path_for resource
    resource == Admin ? admin_root_path : root_path
  end

  def expire_content_cache
    expire_fragment %r{.*}
  end

  def catch_exceptions
    yield
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def get_categories
  end
end
