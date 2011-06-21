require 'spec_helper'

describe "admin/pages/new.html.haml" do
  before :each do
    @category = mock_model(Category, :name => "Folks", :id => 1).as_null_object
    assign :categories, [@category]
    @page = mock_model(Page, :category => @category).as_new_record.as_null_object
    assign :page, @page
  end
  
  it "shows link to list of pages" do
    render
    rendered.should have_selector("a", :href => admin_pages_path)
  end
  
  it "renders a form to create a page" do
    render
    rendered.should have_selector("form", :method => "post",
                                  :action => admin_pages_path) do |form|
      form.should have_selector("select", :name => "page[category_id]") do |s|
        s.should have_selector("option", :value => "1") do |opt|
          opt.should contain("Folks")
        end
      end
      form.should have_selector("input", :type => "text", :name => "page[name]")
      form.should have_selector("textarea", :name => "page[text]")
      form.should have_selector("input", :type => "text", :name => "page[url_match]")
      form.should have_selector("input", :type => "checkbox", :name => "page[enabled]")
      form.should have_selector("input", :type => "text", :name => "page[show_order]")
      form.should have_selector("input", :type => "submit", :name => "commit")
      form.should have_selector("input", :type => "submit", :name => "apply")
    end
  end
end