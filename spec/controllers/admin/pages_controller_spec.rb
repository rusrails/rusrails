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

    describe "GET index" do
      before :each do
        @category = mock_model(Category).as_null_object
        @category.stub_chain(:pages,:ordered).and_return []
        @page = mock_model(Page).as_null_object
        Page.stub(:ordered).and_return [@page]
        Category.stub(:find_by_id).and_return nil
        Category.stub(:ordered).and_return [@category]
      end
      
      it "assign @categories" do
        get :index
        assigns(:categories).should == [@category]
      end
      
      it "checks category filter" do
        Category.should_receive(:find_by_id).with '1'
        get :index, :category_id => '1'
      end
      
      context "when no category filter" do
        it "assign @pages" do
          get :index
          assigns(:pages).should == [@page]
        end
      end
    
      context "when category filter present" do
        it "assign @pages only belonging to this category" do
          Category.stub(:find_by_id).and_return @category
          get :index, :category_id => '1'
          assigns(:pages).should == []
        end
      end
      
      it "renders index view" do
        get :index
        response.should render_template(:index)
      end
    end
    
    describe "GET 'new'" do
      before :each do
        @category = mock_model(Category).as_null_object
        @page = mock_model(Page).as_new_record.as_null_object
        Category.stub(:ordered).and_return [@category]
        Page.stub(:new).and_return @page
      end
      
      it "assign @categories" do
        get :new
        assigns(:categories).should == [@category]
      end
      
      it "assigns @page as new page" do
        Page.should_receive(:new)
        get :new
        assigns[:page].should == @page
      end
      
      it "creates new page from flash[:page]" do
        Page.should_receive(:new).with "name"=>"Tiptoeing", "url_match"=>"tiptoeing"
        get :new,nil,nil,{:page => {"name"=>"Tiptoeing", "url_match"=>"tiptoeing"}}
      end
      
      it "renders new template" do
        get :new
        response.should render_template(:new)
      end
    end
    
    describe "POST 'create'" do
      before :each do
        @page = mock_model(Page, :save => true).as_new_record.as_null_object
        Page.stub(:new).and_return @page
      end
      
      it "creates new page" do
        Page.should_receive(:new).with "name"=>"Tiptoeing", "url_match"=>"tiptoeing"
        post :create, :page => {"name"=>"Tiptoeing", "url_match"=>"tiptoeing"}
      end
      
      it "saves the page" do
        @page.should_receive :save
        post :create
      end
      
      context "when saving succesfull" do
        it "sets flash[:notice]" do
          post :create
          flash[:notice].should_not be_empty
        end
        
        it "redirects to pages index" do
          post :create
          response.should redirect_to(admin_pages_path)
        end
      end
      
      context "when saving failed" do
        before :each do
          @page.stub(:save).and_return false
        end
        
        it "sets flash[:alert]" do
          post :create
          flash[:alert].should_not be_empty
        end
        
        it "sets flash[:page] with params[:page]" do
          post :create, :page => {"name"=>"Tiptoeing", "url_match"=>"tiptoeing"}
          flash[:page].should == {"name"=>"Tiptoeing", "url_match"=>"tiptoeing"}
        end
        
        it "redirects to new page" do
          post :create
          response.should redirect_to(new_admin_page_path)
        end
      end
    end
    
    
  end
end
