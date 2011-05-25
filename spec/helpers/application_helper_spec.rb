require 'spec_helper'

describe ApplicationHelper do
  describe "menu" do
    it "renders list of categories"
    context "when @category present" do
      it "renders list of active pages that belongs to @category"
      
      it "renders that list of pages within category list item"
      
      it "marks category as selected"
      
      context "when @page present" do
        it "marks page as selected"
      end
    end  
  end
end
