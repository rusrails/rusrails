require 'spec_helper'

describe "pages/show.html.haml" do
  before :each do
    assign :page, mock_model(Page,
                              :name=>"Page 11",
                              :text => "<p class='text'>Page 11 text</p>",
                              :url_match => "page-11").as_null_object
    view.stub :page_cache_key
    render
  end

  it "displays a title of homepage" do
    rendered.should contain("Page 11")
  end

  it "displays a text of homepage" do
    rendered.should contain("Page 11 text")
  end

  it "displays tags" do
    rendered.should have_selector("p", :class => "text")
  end
end
