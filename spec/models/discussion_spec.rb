require 'spec_helper'

describe Discussion do
  before do
    @discussion = FactoryGirl.create :discussion
  end
  it "uses counter caching"

  describe "scope :enabled" do
    before :each do
      @disabled_discussion = FactoryGirl.create :discussion, enabled: false
    end

    it "returns enabled discussions" do
      Discussion.enabled.should include(@discussion)
    end

    it "doesn't return disabled discussions"do
      Discussion.enabled.should_not include(@disabled_discussion)
    end

    it "returns discussions ordered by update time 1" do
      @second_discussion = FactoryGirl.create :discussion, updated_at: Time.now + 1.second
      Discussion.enabled.should == [@second_discussion, @discussion]
    end
  end
end
