require './spec/spec_helper'

require 'time'

describe OpenHouse do
  subject do
    OpenHouse.new(
      'ResourceUri'=>"/v1/listings/20060412165917817933000000/openhouses/20101127153422574618000000",
      'Id'=>"20060412165917817933000000",
      'Date'=>"10/01/2010",
      'StartTime'=>"9:00 am",
      'EndTime'=>"12:00 pm"
    )
  end

  it "should respond to a few methods" do
    expect(subject.class).to respond_to(:find_by_listing_key)
  end

  context "/listings/<listing_id>/openhouses", :support do
    on_get_it "should get open house for a listing" do
      stub_auth_request
      stub_api_get('/listings/20060412165917817933000000/openhouses','listings/open_houses.json')
      houses = subject.class.find_by_listing_key('20060412165917817933000000')
      expect(houses).to be_an(Array)
      expect(houses.length).to eq(2)
      expect(houses.first.Id).to eq("20101127153422574618000000")
    end
  end

end
