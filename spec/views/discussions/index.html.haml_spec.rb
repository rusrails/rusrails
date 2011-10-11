require 'spec_helper'

describe "discussions/index.html.haml" do
  let(:author){ mock_model User, :name => "Steve" }
  let(:says){ double "says", :count => 10 }
  let(:discussion){ mock_model Discussion, :title => "New question", :author => author, :says => says, :updated_at => Time.now }
  before do
    assign :discussions, [discussion]
    render
  end

  context "for each discussion" do
    it "displays title" do
      rendered.should contain("New question")
    end

    it "displays author" do
      rendered.should contain("Steve")
    end

    it "displays link" do
      rendered.should have_selector(:a, :href => discussion_path(discussion))
    end

    it "displays update time" do
      rendered.should contain("обновлено #{l discussion.updated_at, :format => :short}")
    end

    it "dispalys count of says" do
      rendered.should contain("10 сообщений")
    end
  end

  it "shows pagination"

  it "shows link for new discussion" do
    rendered.should have_selector(:a, :href => new_discussion_path)
  end
end
