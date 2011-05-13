require 'spec_helper'

describe Category do
  before :each do
    @category = Category.new :name => "Category 1", :url_match => "category_1"
  end
  
  it "is valid with valid attributes" do
    @category.should be_valid
  end
  
  it "is not valid without name" do
    @category.name = nil
    @category.should_not be_valid
  end
  
  it "is not valid without url_match" do
    @category.url_match = nil
    @category.should_not be_valid
  end
end
