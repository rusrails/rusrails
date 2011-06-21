require 'spec_helper'

describe "categories/show.html.haml" do
  before :each do
    @category = mock_model(Category, :name=>"Category 1",
                                 :text => "<p class='text'>Category 1 text</p>",
                                 :url_match => "category-1").as_null_object
    assign :category, @category
    @page1 = mock_model(Page, :name=>"Lady", :path => "category-1/lady").as_null_object
    @page2 = mock_model(Page, :name=>"Good", :path => "category-1/good").as_null_object
    @category.stub(:pages).and_return [@page1, @page2]
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
  
  it "displays list of links to pages" do
    rendered.should have_selector("ul") do |ul|
      ul.should have_selector("a", :href => "category-1/lady") do |link|
        link.should contain("Lady")
      end
      ul.should have_selector("a", :href => "category-1/good") do |link|
        link.should contain("Good")
      end
    end
  end
end
