require 'spec_helper'

describe PagesController do
  describe "GET index" do
    let(:homepage){ mock_model(Page) }
    let(:category){mock_model(Category)}
    before :each do
      Page.stub(:matching).with("home").and_return homepage
      Category.stub(:enabled).and_return [category]
    end
    
    it "loads homepage if present" do
      Page.should_receive(:matching)
      get :index
    end
    
    it "creates new empty homepage if it isn't present yet" do
      Page.should_receive(:matching).with("home").and_return nil
      Page.should_receive(:create).with(:name => "Homepage", :url_match => "home").and_return homepage
      get :index
    end
    
    it "assigns @homepage" do
      get :index
      assigns[:homepage].should eq(homepage)
    end
    
    it "gives list of categories (for menu helper)" do
      Category.should_receive(:enabled)
      get :index
      assigns[:categories].should eq([category])
    end
    
    it "renders index template" do
      get :index
      response.should render_template("index")
    end
  end
  
  describe "GET show" do
    let(:category){mock_model(Category)}
    let(:page){mock_model(Page)}
    before :each do
      Category.stub(:matching).and_return category
      Category.stub(:enabled).and_return [category]
      category.stub_chain(:pages,:matching).and_return page
      category.stub_chain(:pages,:enabled).and_return [page]
    end
    
    it "tries to load matching category" do
      Category.should_receive(:matching).with "category-1"
      get :show, :category_url_match=>"category-1", :url_match=>"page-11"
    end
    
    context "when matching category present" do
      context "when matching page present" do
        it "assigns @category" do
          get :show, :category_url_match=>"category-1", :url_match=>"page-11"
          assigns(:category).should == category
        end
        
        it "assigns @page" do
          get :show, :category_url_match=>"category-1", :url_match=>"page-11"
          assigns(:page).should == page
        end
        
        it "assigns @categories (for menu helper)" do
          Category.should_receive(:enabled)
          get :show, :category_url_match=>"category-1", :url_match=>"page-11"
          assigns[:categories].should eq([category])
        end
        
        it "assigns @pages (for menu helper)" do
          get :show, :category_url_match=>"category-1", :url_match=>"page-11"
          assigns[:pages].should eq([page])
        end
        
        it "renders show template" do
          get :show, :category_url_match=>"category-1", :url_match=>"page-11"
          response.should render_template("show")
        end
      end
      
      context "when no matching page" do
        before :each do
          category.stub_chain(:pages,:matching).and_return nil
        end
        
        it "renders 404 page" do
          get :show, :category_url_match=>"category-1", :url_match=>"no-page"
          response.should render_template('pages/404')
        end
        
        it "should not load list of categories" do
          Category.should_not_receive(:enabled)
          get :show, :category_url_match=>"category-1", :url_match=>"no-page"
        end
      end
    end
    
    context "when no matching category" do
      before :each do
        Category.stub(:matching).and_return nil
      end
      
      it "renders 404 page" do
        get :show, :category_url_match=>"no-category", :url_match=>"page-11"
        response.should render_template('pages/404')
      end
      
      it "should not load list of categories" do
        Category.should_not_receive(:enabled)
        get :show, :category_url_match=>"no-category", :url_match=>"page-11"
      end
    end
  end
end
