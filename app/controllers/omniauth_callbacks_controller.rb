class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.find_or_create_for_github env["omniauth.auth"]
    flash[:notice] = "Успешно вошли через Github"
    sign_in_and_redirect @user, :event => :authentication
  end

  def twitter
    @user = User.find_or_create_for_twitter env["omniauth.auth"]
    flash[:notice] = "Успешно вошли через Twitter"
    sign_in_and_redirect @user, :event => :authentication
  end

  def google
    @user = User.find_or_create_for_google env["omniauth.auth"]
    flash[:notice] = "Успешно вошли через Google"
    sign_in_and_redirect @user, :event => :authentication
  end

  def passthru
    render_404
  end
end
