require 'spec_helper'

describe DiscussionsController do
  describe "#index" do
    let(:discussion){ mock_model Discussion }
    before do
      Discussion.stub(:enabled).and_return [discussion]
    end

    it "loads enabled discussions" do
      Discussion.should_receive :enabled
      get :index
    end

    it "paginates discussions"

    it "assigns @discussions" do
      get :index
      assigns[:discussions].should == [discussion]
    end

    it "renders index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "#show" do
    let(:discussion){ mock_model Discussion }
    before do
      Discussion.stub_chain(:enabled, :find).and_return discussion
    end

    it "finds enabled discussion" do
      Discussion.enabled.should_receive(:find).with 10
      get :show, :id => 10
    end

    it "assigns @discussion" do
      get :show, :id => 10
      assigns[:discussion].should == discussion
    end

    it "renders show template" do
      get :show, :id => 10
      response.should render_template("show")
    end
  end
end
