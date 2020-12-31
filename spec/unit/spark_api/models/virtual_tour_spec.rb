require './spec/spec_helper'

describe VirtualTour do
  before(:each) do
    @virtualtour = VirtualTour.new({
      :Uri => "http://www.flexmls.com/",
      :ResourceUri => "/v1/listings/20060712220814669202000000/virtualtours/20110105165843978012000000",
      :Name => "My Branded Tour",
      :Id => "20110105165843978012000000",
      :Type => "branded"
    })
  end

  it "should respond to a few methods" do
    expect(VirtualTour).to respond_to(:find_by_listing_key)
    expect(@virtualtour).to respond_to(:branded?)
    expect(@virtualtour).to respond_to(:unbranded?)
  end

  it "should know if it's branded" do
    expect(@virtualtour.branded?).to eq(true)
    expect(@virtualtour.unbranded?).to eq(false)
  end

  context "/listings/<listing_id>/virtualtours", :support do
    on_get_it "should get virtual tours for a listing" do
      stub_auth_request
      stub_api_get('/listings/1234/virtualtours','listings/virtual_tours_index.json')

      v = VirtualTour.find_by_listing_key('1234')
      expect(v).to be_an(Array)
      expect(v.length).to eq(5)
    end
  end

  context "/listings/<listing_id>/virtualtours/<tour_id>", :support do
    on_get_it "should return information about a specific virtual tour"
  end

  after(:each) do
    @virtualtour = nil
  end

end
