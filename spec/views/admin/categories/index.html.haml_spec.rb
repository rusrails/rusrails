require 'spec_helper'

describe "admin/categories/index.html.haml" do
  before :each do
    @category = mock_model(Category, :id => 1, :name=>"Category 1", :enabled => true,
                           :path => "/category-1").as_null_object
    assign :categories, [@category]
  end
  
  it "shows link for creating new category" do
    render
    rendered.should have_selector("a", :href => new_admin_category_path)
  end
  
  context "when some categories present" do
    it "shows category's name" do
      render
      rendered.should contain("Category 1")
    end
    
    it "shows category's link" do
      render
      rendered.should have_selector("a", :href => "/category-1")
    end
    
    it "shows link for toggle enable/disable" do
      view.should_receive(:link_to_toggle).with @category
      render
    end
    
    it "shows link to edit category" do
      render
      rendered.should have_selector("a", :href => edit_admin_category_path(@category))
    end
    
    it "shows link to destroy category" do
      render
      rendered.should have_selector("a", "data-method" => "delete",
                                    :href => admin_category_path(@category))
    end
  end
end