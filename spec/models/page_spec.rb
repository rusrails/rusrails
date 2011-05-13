require 'spec_helper'

describe Page do
  before :each do
    @page = Page.new :name => "Page 11", :url_match => "page_11"
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
end
