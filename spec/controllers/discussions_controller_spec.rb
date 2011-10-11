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
end
