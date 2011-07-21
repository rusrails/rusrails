require 'spec_helper'

describe "search/show.html.haml" do
  let(:page){ mock_model(Page, :name => "Page 11", :path => "/cat/page-11", :category => nil)}
  let(:category){ mock_model(Category, :name => "Cat", :path => "/cat")}
  before :each do
    assign :result, [category, page]
    assign :search, "foobar"
  end
  
  it "displays search query" do
    render
    rendered.should have_selector("h1") do |header|
      header.should contain("foobar")
    end
  end
  
  it "displays pages in result" do
    render
    rendered.should have_selector("a", :href => "/cat/page-11") do |link|
      link.should contain("Page 11")
      link.should_not contain("/")
    end
  end
  
  it "displays categories in result" do
    render
    rendered.should have_selector("a", :href => "/cat") do |link|
      link.should contain("Cat")
    end
  end

  it "displays page's category in result" do
    page.stub(:category).and_return category
    render
    rendered.should have_selector("a", :href => "/cat/page-11") do |link|
      link.should contain("Cat")
      link.should contain("/")
    end
  end
end
