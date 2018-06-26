require 'spec_helper'

describe Activity do

  before :each do
    stub_auth_request
  end

  context '/activities' do
    it "gets a current user's activities" do
      s = stub_api_get("/activities", "activities/get.json")
      activities = Activity.get
      expect(activities).to be_an(Array)
      expect(activities.size).to eq(2)
      expect(s).to have_been_requested
    end
  end

  context '/activities/<id>' do
    let(:id) { "20121128132106172132000004" }
    it "gets an individual activity" do
      s = stub_api_get("/activities/#{id}", "activities/get.json")
      activity = Activity.find(id)
      expect(activity).to be_an(Activity)
      expect(s).to have_been_requested
    end
  end

end
