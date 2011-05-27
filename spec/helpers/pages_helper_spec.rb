require 'spec_helper'

describe PagesHelper do
  describe "#prev_page_link" do
    before :each do
      @page1 = mock_model "Page", :name => "Page 1", :path => "/category-1/page-1"
      @page2 = mock_model "Page", :name => "Page 2", :path => "/category-1/page-2"
      assign :pages, [@page1,@page2]
    end
    
    context "when current page is first in pages collection" do
      it "returns nothing" do
        assign :page, @page1
        helper.prev_page_link.should == nil
      end
    end
    
    context "when current page is not first in pages collection" do
      before :each do
        assign :page, @page2
      end
      
      it "returns link to previous page" do
        helper.prev_page_link.should have_selector("a", :href => "/category-1/page-1")
      end
      
      it "returns link with class 'prev_page'" do
        helper.prev_page_link.should have_selector("a.prev_page")
      end
      
      it "set caption for link as previous page's name" do
        helper.prev_page_link.should contain("Page 1")
      end
    end
  end
  
  describe "#next_page_link" do
    before :each do
      @page1 = mock_model "Page", :name => "Page 1", :path => "/category-1/page-1"
      @page2 = mock_model "Page", :name => "Page 2", :path => "/category-1/page-2"
      assign :pages, [@page1,@page2]
    end
    
    context "when current page is last in pages collection" do
      it "returns nothing" do
        assign :page, @page2
        helper.next_page_link.should == nil
      end
    end
    
    context "when current page is not last in pages collection" do
      before :each do
        assign :page, @page1
      end
      
      it "returns link to next page" do
        helper.next_page_link.should have_selector("a", :href => "/category-1/page-2")
      end
      
      it "returns link with class 'next_page'" do
        helper.next_page_link.should have_selector("a.next_page")
      end
      
      it "set caption for link as next page's name" do
        helper.next_page_link.should contain("Page 2")
      end
    end
  end
end