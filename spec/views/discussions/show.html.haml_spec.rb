require 'spec_helper'

describe "discussions/show.html.haml" do
  let(:say1){ mock_model Say, :text => "Some questions", :updated_at => Time.now - 10.days, :author => mock_model(User, :name => "Steve") }
  let(:say2){ mock_model Say, :text => "I answer you", :updated_at => Time.now, :author => mock_model(User, :name => "Bill") }
  let(:says){ [say1, say2] }
  let(:discussion){ mock_model Discussion, :title => "New question", :says => says, :updated_at => Time.now }
  before do
    assign :discussion, discussion
    render
  end

  it "shows discussion title" do
    rendered.should contain("New question")
  end

  describe "discussion's says" do
    it "shows title" do
      rendered.should contain("Some questions")
      rendered.should contain("I answer you")
    end

    it "shows time" do
      rendered.should contain("#{l say1.updated_at, :format => :short}")
      rendered.should contain("#{l say2.updated_at, :format => :short}")
    end

    it "shows author" do
      rendered.should contain("Steve")
      rendered.should contain("Bill")
    end
  end

  it "shows form for new say for registered"

  it "shows login link for guest"
end
