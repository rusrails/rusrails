require 'spec_helper'

describe Page do
  before :each do
    @page = Factory :page, :name => "Page 11", :url_match => "page_11"
  end
  
  it "is valid with valid attributes" do
    @page.should be_valid
  end
  
  it "is not valid without name" do
    @page.name = nil
    @page.should_not be_valid
  end
  
  it "is not valid without url_match" do
    @page.url_match = nil
    @page.should_not be_valid
  end
  
  describe "scope :matching" do
    it "returns page, matching given url, if exist" do
      Page.matching("page_11").should == @page
    end
    
    it "returns nil, if page, matching given url, not exist" do
      Page.matching("wrong_page").should == nil
    end
    
    context "for given page collection, belonging to category" do
      before :each do
        @category = Factory :category, :name => "Ctg 1", :url_match => "ctg_1"
        @category.pages << @page
      end
      
      it "returns page, matching given url, if exist" do
        @category.pages.matching("page_11").should == @page
      end
      
      it "returns nil, if page, matching given url, not exist" do
        @category.pages.matching("wrong_page").should == nil
      end
      
      it "returns nil, if page, matching given url, not belong that category" do
        @page.category = nil
        @page.save
        @category.pages.matching("page_11").should == nil
      end
    end
  end
end
