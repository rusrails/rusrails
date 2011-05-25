require 'spec_helper'

describe "pages/index.html.erb" do
  before :each do
    assign :homepage, mock_model(Page,
                                 :name=>"Homepage",
                                 :text => "<p class='text'>Homepage text</p>",
                                 :url_match => "home").as_null_object
    render
  end
  
  it "displays a title of homepage" do
    rendered.should contain("Homepage")
  end
  
  it "displays a text of homepage" do
    rendered.should contain("Homepage text")
  end
  
  it "displays tags" do
    rendered.should have_selector("p", :class => "text")
  end
end
