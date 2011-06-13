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
    
    describe "GET 'new'" do
      let(:category){mock_model(Category).as_new_record}
      before :each do
        Category.stub(:new).and_return category
      end
      
      it "assigns @category as new category" do
        Category.should_receive(:new)
        get :new
        assigns[:category].should == category
      end
      
      it "creates new category from flash[:category]" do
        Category.should_receive(:new).with "name"=>"Category 1", "url_match"=>"category-1"
        get :new,nil,nil,{:category => {"name"=>"Category 1", "url_match"=>"category-1"}}
      end
      
      it "renders new template" do
        get :new
        response.should render_template(:new)
      end
    end
    
    describe "POST 'create'" do
      let(:category){mock_model(Category, :save => true).as_new_record.as_null_object}
      before :each do
        Category.stub(:new).and_return category
      end
      
      it "creates new category" do
        Category.should_receive(:new).with "name"=>"Category 1", "url_match"=>"category-1"
        post :create, :category => {"name"=>"Category 1", "url_match"=>"category-1"}
      end
      
      it "saves the category" do
        category.should_receive :save
        post :create
      end
      
      context "when saving succesfull" do
        it "sets flash[:notice]" do
          post :create
          flash[:notice].should=~ /.+/
        end
        
        it "redirects to categories index" do
          post :create
          response.should redirect_to(admin_categories_path)
        end
      end
      
      context "when saving failed" do
        before :each do
          category.stub(:save).and_return false
        end
        
        it "sets flash[:alert]" do
          post :create
          flash[:alert].should=~ /.+/
        end
        
        it "sets flash[:category] with params[:category]" do
          post :create, :category => {"name"=>"Category 1", "url_match"=>"category-1"}
          flash[:category].should == {"name"=>"Category 1", "url_match"=>"category-1"}
        end
        
        it "redirects to new category" do
          post :create
          response.should redirect_to(new_admin_category_path)
        end
      end
    end
    
    describe "GET 'edit'" do
      let(:category){ mock_model Category }
      before :each do
        Category.stub(:find).and_return category
      end
      
      it "assigns @category as finded category" do
        Category.should_receive(:find).with 1
        get :edit, :id => 1
        assigns[:category].should == category
      end
      
      it "renders edit template" do
        get :edit, :id => 1
        response.should render_template(:edit)
      end
    end
  end
end
