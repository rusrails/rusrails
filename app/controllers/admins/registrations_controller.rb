class Admin::RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to admin_root_path
  end
  
  def create
    redirect_to admin_root_path
  end
  
  def destroy
    redirect_to admin_root_path
  end
end
