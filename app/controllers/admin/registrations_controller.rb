class Admin::RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to admin_path
  end
  
  def create
    redirect_to admin_path
  end
end
