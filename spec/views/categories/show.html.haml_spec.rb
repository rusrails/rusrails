require 'spec_helper'

describe "categories/show.html.haml" do
  before :each do
    assign :category, mock_model(Category,
                                 :name=>"Category 1",
                                 :text => "<p class='text'>Category 1 text</p>",
                                 :url_match => "category-1").as_null_object
    render
  end
  
  it "displays a title of category" do
    rendered.should contain("Category 1")
  end
  
  it "displays a text of category" do
    rendered.should contain("Category 1 text")
  end
  
  it "displays tags" do
    rendered.should have_selector("p", :class => "text")
  end
end
