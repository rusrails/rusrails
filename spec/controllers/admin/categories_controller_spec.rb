require 'spec_helper'

describe Admin::CategoriesController do
  it "redirects to sign in form, when not admin" do
    get :index
    response.should redirect_to(new_admin_session_path)
    get :new
    response.should redirect_to(new_admin_session_path)
    post :create
    response.should redirect_to(new_admin_session_path)
    get :edit, :id => 1
    response.should redirect_to(new_admin_session_path)
    put :update, :id => 1
    response.should redirect_to(new_admin_session_path)
    delete :destroy, :id => 1
    response.should redirect_to(new_admin_session_path)
  end
  
  context "when admin signed up" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
    end
    
    describe "GET 'index'" do
      let(:category){mock_model Category}
      before :each do
        Category.stub(:ordered).and_return [category]
      end
      
      it "assigns @categories" do
        Category.should_receive(:ordered)
        get :index
        assigns[:categories].should eq([category])
      end
      
      it "renders index template" do
        get :index
        response.should render_template(:index)
      end
    end
  end
end
