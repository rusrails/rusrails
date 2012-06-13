require 'spec_helper'

describe Page do
  before :each do
    @page = FactoryGirl.create :page, :name => "Page 11", :url_match => "page_11"
  end

  it "is valid with valid attributes" do
    @page.should be_valid
  end

  it "is not valid without name" do
    @page.name = nil
    @page.should_not be_valid
  end

  it "is not valid without url_match" do
    @page.url_match = nil
    @page.should_not be_valid
  end

  describe "format of url_match" do
    it "is valid when have no slashes" do
      @page.url_match = "some/path"
      @page.should_not be_valid
      @page.url_match = "some\\path"
      @page.should_not be_valid
    end

    it "is valid when #path returns valid url" do
      @page.stub(:path).and_return "wrong path!"
      @page.should_not be_valid
    end

    it "is valid when #path have no host and qs parts" do
      @page.stub(:path).and_return "http://www.domain.ru/some/path"
      @page.should_not be_valid
      @page.stub(:path).and_return "some/path?query=true"
      @page.should_not be_valid
    end
  end

  it "is not valid when homepage belongs to category" do
    @page.url_match = "home"
    @page.category_id = 1
    @page.should_not be_valid
  end

  describe "scope :ordered" do
    it "returns pages ordered by show_order" do
      @second_page = FactoryGirl.create :page, :name => "page 13",
                             :url_match => "page_13", :show_order => -1
      Page.ordered.should == [@second_page,@page]
    end

    it "returns pages with equal show_order ordered by creation time" do
      @second_page = FactoryGirl.create  :page, :name => "page 13", :url_match => "page_13"
      Page.ordered.should == [@page,@second_page]
    end
  end

  describe "scope :enabled" do
    before :each do
      @disabled_page = FactoryGirl.create  :page, :name => "page 12",
                                :url_match => "page_12", :enabled => false
      @category = FactoryGirl.create :category, :name => "Ctg 1", :url_match => "ctg_1"
      @category.pages << @page << @disabled_page
    end

    it "returns enabled pages within category" do
      @category.pages.enabled.should include(@page)
    end

    it "doesn't return disabled pages within category"do
      @category.pages.enabled.should_not include(@disabled_page)
    end
  end

  describe "self.matching" do
    it "returns page, matching given url, if exist" do
      Page.matching("page_11").should == @page
    end

    it "returns nil, if page, matching given url, not exist" do
      Page.matching("wrong_page").should == nil
    end

    context "for given page collection, belonging to category" do
      before :each do
        @category = FactoryGirl.create :category, :name => "Ctg 1", :url_match => "ctg_1"
        @category.pages << @page
      end

      it "returns page, matching given url, if exist" do
        @category.pages.matching("page_11").should == @page
      end

      it "returns nil, if page, matching given url, not exist" do
        @category.pages.matching("wrong_page").should == nil
      end

      it "returns nil, if page, matching given url, not belong that category" do
        @page.category = nil
        @page.save
        @category.pages.matching("page_11").should == nil
      end
    end
  end

  describe "#path" do
    it "returns path to page based on url_match if page without category" do
      @page.path.should == "/page_11"
    end

    it "returns path to page based on url_matches of page and category if present" do
      @category = FactoryGirl.create :category, :name => "Ctg 1", :url_match => "ctg_1"
      @category.pages << @page
      @page.path.should == "/ctg_1/page_11"
    end
  end
end
