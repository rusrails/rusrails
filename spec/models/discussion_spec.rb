require 'spec_helper'

describe Discussion do
  before do
    @discussion = Factory :discussion
  end
  it "uses counter caching"

  describe "scope :enabled" do
    before :each do
      @disabled_discussion = Factory :discussion, :enabled => false
    end

    it "returns enabled discussions" do
      Discussion.enabled.should include(@discussion)
    end

    it "doesn't return disabled discussions"do
      Discussion.enabled.should_not include(@disabled_discussion)
    end


    it "returns discussions ordered by update time" do
      @second_discussion = Factory :discussion, :updated_at => Time.now + 1.second
      Discussion.enabled.should == [@second_discussion, @discussion]

      @discussion.update_attributes :updated_at => Time.now + 2.seconds
      Discussion.enabled.should == [@discussion, @second_discussion]
    end
  end
end
