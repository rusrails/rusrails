require 'spec_helper'

describe "admin/categories/edit.html.haml" do
  before :each do
    @category = mock_model(Category).as_null_object
    assign :category, @category
  end
  
  it "shows link to list of categories" do
    render
    rendered.should have_selector("a", :href => admin_categories_path)
  end
  
  it "renders a form to update a category" do
    render
    rendered.should have_selector("form", :method => "post",
                                  :action => admin_category_path(@category)) do |form|
      form.should have_selector("input",:type => "hidden",:name => "_method",:value=>"put")
      form.should have_selector("input", :type => "text", :name => "category[name]")
      form.should have_selector("textarea", :name => "category[text]")
      form.should have_selector("input", :type => "text", :name => "category[url_match]")
      form.should have_selector("input", :type => "checkbox", :name => "category[enabled]")
      form.should have_selector("input", :type => "text", :name => "category[show_order]")
      form.should have_selector("input", :type => "submit")
    end
  end
end