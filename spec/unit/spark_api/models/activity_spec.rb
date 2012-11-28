require 'spec_helper'

describe Activity do

  before :each do
    stub_auth_request
  end

  context '/activities' do
    it "gets a current user's activities" do
      s = stub_api_get("/activities", "activities/get.json")
      activities = Activity.get
      activities.should be_an(Array)
      activities.size.should eq(2)
      s.should have_been_requested
    end
  end

  context '/activities/<id>' do
    let(:id) { "20121128132106172132000004" }
    it "gets an individual activity" do
      s = stub_api_get("/activities/#{id}", "activities/get.json")
      activity = Activity.find(id)
      activity.should be_an(Activity)
      s.should have_been_requested
    end
  end

end
