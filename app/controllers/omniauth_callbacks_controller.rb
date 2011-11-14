class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.find_or_create_for_github env["omniauth.auth"]
    flash[:notice] = "Успешно вошли через Github"
    sign_in_and_redirect @user, :event => :authentication
  end

  def passthru
    render_404
  end
end
