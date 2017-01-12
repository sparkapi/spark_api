require './spec/spec_helper'


describe Newsfeed do

  before do
    stub_auth_request
  end

  describe "update!" do
    it "should update the attributes" do
      stub_api_get("/newsfeeds/20130625195235039712000000", "newsfeeds/get.json")
      stub_api_put("/newsfeeds/20130625195235039712000000", {:Active => false}, "newsfeeds/inactive.json")
      @newsfeed = Newsfeed.find("20130625195235039712000000")
      @newsfeed.update!(:Active => false)
      expect(@newsfeed.Active) == false
    end
  end
end
