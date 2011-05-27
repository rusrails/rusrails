require 'spec_helper'

describe ApplicationHelper do
  describe "#menu" do
    before :each do
      @cat1 = mock_model "Category", :name => "Category 1", :path => "/category-1"
      @cat2 = mock_model "Category", :name => "Category 2", :path => "/category-2"
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
      menu.should contain("Category 1")
      menu.should contain("Category 2")
    end
    
    specify {helper.menu.should be_html_safe}
    
    context "when @category present" do
      before :each do
        @page1 = mock_model "Page", :name => "Page 1", :path => "/category-1/page-1"
        @page2 = mock_model "Page", :name => "Page 2", :path => "/category-1/page-2"
        @cat1.stub_chain(:pages, :enabled).and_return Array[@page1,@page2]
        assign :category, @cat1
      end
      
      it "marks category as selected" do
        menu = helper.menu
        menu.should have_selector("li.selected a", :href => "/category-1")
      end
      
      it "renders links to active pages which belongs to @category" do
        menu = helper.menu
        menu.should have_selector("a", :href => "/category-1/page-1")
        menu.should have_selector("a", :href => "/category-1/page-2")
      end
      
      it "renders names of active pages which belongs to @category" do
        menu = helper.menu
        menu.should contain("Page 1")
        menu.should contain("Page 2")
      end
      
      it "renders its list of pages within active category's list item" do
        menu = helper.menu
        menu.should have_selector(".menu>li.selected") do |li|
          li.should contain("Page 1")
          li.should contain("Page 2")
        end
      end
      
      context "when @page present" do
        it "marks page as selected" do
          assign :page, @page1
          menu = helper.menu
          menu.should have_selector("li.category_pages li.selected a",
                                    :href => "/category-1/page-1")
        end
      end
    end  
  end
  
  describe "#selected_class" do
    context "when condition is true" do
      it "return nil if no other classes" do
        helper.selected_class(false).should == nil
      end
      
      it "return hash with :class key if other classes present" do
        helper.selected_class(false,"foo","bar").should == {:class => "foo bar"}
      end
    end
    
    context "when condition is true" do
      it "return hash with :class key if no other classes" do
        helper.selected_class(true).should == {:class => "selected"}
      end
      it "return hash with :class key if other classes present" do
        helper.selected_class(true,"foo","bar").should == {:class => "foo bar selected"}
      end
    end
  end
end
