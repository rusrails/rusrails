require 'spec_helper'

describe ApplicationHelper do
  describe "#menu" do
    before :each do
      @cat1 = mock_model("Category", :name => "Category 1",
                         :path => "/category-1").as_null_object
      @cat2 = mock_model("Category", :name => "Category 2",
                         :path => "/category-2").as_null_object
      assign :categories, [@cat1,@cat2]
    end
    
    it "render nothing if no categories" do
      assign :categories, []
      helper.menu.should == nil
      assign :categories, nil
      helper.menu.should == nil
    end
    
    it "renders links to all categories" do
      menu = helper.menu
      menu.should have_selector("a", :href => "/category-1")
      menu.should have_selector("a", :href => "/category-2")
    end
    
    it "renders names of categories" do
      menu = helper.menu
      menu.should include("Category 1")
      menu.should include("Category 2")
    end
    
    context "when @category present" do
      it "renders list of active pages that belongs to @category"
      
      it "renders that list of pages within category list item"
      
      it "marks category as selected"
      
      context "when @page present" do
        it "marks page as selected"
      end
    end  
  end
end
