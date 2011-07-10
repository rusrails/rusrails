require 'spec_helper'

describe SearchController do
  describe "GET show" do
    let(:page){ mock_model(Page).as_null_object }
    let(:category){ mock_model(Category).as_null_object }
    before :each do
      ThinkingSphinx.stub(:search).and_return [page, category]
      Category.stub(:enabled).and_return [category]
    end
    
    it "assigns @search" do
      get :show, :search => "foobar"
      assigns[:search].should == "foobar"
    end
    
    it "asks sphinx for matching records" do
      ThinkingSphinx.should_receive(:search)
      get :show, :search => "foobar"
    end
    
    it "assigns @result" do
      get :show, :search => "foobar"
      assigns[:result].should == [page, category]
    end
    
    it "assigns @categories (for menu helper)" do
      Category.should_receive(:enabled)
      get :show, :url_match=>"category-1"
      assigns[:categories].should eq([category])
    end
    
    it "renders show template" do
      get :show, :search => "foobar"
      response.should render_template("show")
    end
  end
end
