require 'spec_helper'

describe CategoriesController do
  describe "GET 'show'" do
    let(:category){mock_model(Category)}
    before :each do
      Category.stub(:matching).and_return category
      Category.stub(:enabled).and_return [category]
    end
    
    it "tries to load matching category" do
      Category.should_receive(:matching).with "category-1"
      get :show, :url_match=>"category-1"
    end
    
    context "when matching category present" do
      it "assigns @category" do
        get :show, :url_match=>"category-1"
        assigns(:category).should == category
      end
      
      it "assigns @categories (for menu helper)" do
        Category.should_receive(:enabled)
        get :show, :url_match=>"category-1"
        assigns[:categories].should eq([category])
      end
      
      it "renders show template" do
        get :show, :url_match=>"category-1"
        response.should render_template("show")
      end
    end
    
    context "when no matching category" do
      before :each do
        Category.stub(:matching).and_return nil
      end
      
      it "renders 404 page" do
        get :show, :url_match=>"no-category"
        response.should render_template('pages/404')
      end
      
      it "should not load list of categories" do
        Category.should_not_receive(:enabled)
        get :show, :url_match=>"no-category"
      end
    end
  end

end
