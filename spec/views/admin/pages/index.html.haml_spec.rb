require 'spec_helper'

describe "admin/pages/index.html.haml" do
  before :each do
    @category = mock_model(Category, :id => 1, :name=>"Folks").as_null_object
    assign :categories, [@category]
    @page = mock_model(Page, :id => 1, :name=>"City lights",
                       :path => "/folks/city-lights").as_null_object
    assign :pages, [@page]
  end
  
  it "shows link for creating new page" do
    render
    rendered.should have_selector("a", :href => new_admin_page_path)
  end
  
  context "when some pages present" do
    it "shows page's name" do
      render
      rendered.should contain("City lights")
    end
    
    it "shows page's link" do
      render
      rendered.should have_selector("a", :href => "/folks/city-lights")
    end
    
    it "shows link for toggle enable/disable" do
      view.should_receive(:link_to_toggle).with @page
      render
    end
    
    it "shows link to edit page" do
      render
      rendered.should have_selector("a", :href => edit_admin_page_path(@page))
    end
    
    it "shows link to destroy page" do
      render
      rendered.should have_selector("a", "data-method" => "delete",
                                    :href => admin_page_path(@page))
    end
    
    it "shows form for editing show_order" do
      render
      rendered.should have_selector("form", :method => "post",
                                    :action => admin_page_path(@page)) do |form|
        form.should have_selector("input", :type => "hidden", :name => "_method",
                                  :value=>"put")
        form.should have_selector("input", :type => "text", :name=> "page[show_order]")
      end
    end
  end
end