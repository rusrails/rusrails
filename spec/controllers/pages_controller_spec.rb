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
      Page.should_receive(:create)
          .with(:name => "Homepage", :url_match => "home").and_return homepage
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
end
