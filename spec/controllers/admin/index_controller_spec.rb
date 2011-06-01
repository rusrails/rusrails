require 'spec_helper'

describe Admin::IndexController do

  describe "GET 'index'" do
    it "redirects to sign in form, when not admin" do
      get :index
      response.should redirect_to(new_admin_session_path)
    end
    
    it "renders index view for admin" do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
      get :index
      response.should render_template(:index)
    end
  end

end
