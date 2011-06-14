require 'spec_helper'

describe Admin::PagesController do
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
      let(:page){mock_model Page}
      before :each do
        Page.stub(:ordered).and_return [page]
      end
      
      it "assigns @pages" do
        Page.should_receive(:ordered)
        get :index
        assigns[:pages].should eq([page])
      end
      
      it "renders index template" do
        get :index
        response.should render_template(:index)
      end
    end
  end
end
