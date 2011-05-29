class Admin::IndexController < ApplicationController
  layout 'admin'
  before_filter :check_admin
  
  def index
  end
  
private
  def check_admin
    redirect_to new_admin_session_path unless admin_signed_in?
  end
end
