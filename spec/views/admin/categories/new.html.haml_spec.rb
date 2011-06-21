require 'spec_helper'

describe "admin/categories/new.html.haml" do
  before :each do
    @category = mock_model(Category).as_new_record.as_null_object
    assign :category, @category
  end
  
  it "shows link to list of categories" do
    render
    rendered.should have_selector("a", :href => admin_categories_path)
  end
  
  it "renders a form to create a category" do
    render
    rendered.should have_selector("form", :method => "post",
                                  :action => admin_categories_path) do |form|
      form.should have_selector("input", :type => "text", :name => "category[name]")
      form.should have_selector("textarea", :name => "category[text]")
      form.should have_selector("input", :type => "text", :name => "category[url_match]")
      form.should have_selector("input", :type => "checkbox", :name => "category[enabled]")
      form.should have_selector("input", :type => "text", :name => "category[show_order]")
      form.should have_selector("input", :type => "submit", :name => "commit")
      form.should have_selector("input", :type => "submit", :name => "apply")
    end
  end
end