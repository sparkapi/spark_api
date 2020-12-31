require './spec/spec_helper'

require 'time'

describe TourOfHome do
  subject do
    TourOfHome.new(
      'ResourceUri'=>"/listings/20060725224713296297000000/tourofhomes/20101127153422574618000000",
      'Id'=>"20101127153422574618000000",
      'Date'=>"10/01/2010",
      'StartTime'=>"9:00 am",
      'EndTime'=>"11:00 pm",
      'Comments'=>"Wonderful home; must see!",
      'AdditionalInfo'=> [{"Hosted By"=>"Joe Smith"}, {"Host Phone"=>"123-456-7890"}, {"Tour Area"=>"North-Central"}]
    )
  end

  it "should respond to a few methods" do
    expect(subject.class).to respond_to(:find_by_listing_key)
  end

  context "/listings/<listing_id>/tourofhomes", :support do
    on_get_it "should get home tours for a listing" do
      stub_auth_request
      stub_api_get('/listings/20060725224713296297000000/tourofhomes','listings/tour_of_homes.json')
      v = subject.class.find_by_listing_key('20060725224713296297000000')
      expect(v).to be_an(Array)
      expect(v.length).to eq(2)
    end
  end

  context "/listings/<listing_id>/tourofhomes/<tour_id>", :support do
    on_get_it "should get information for a single tour of a home"
  end

end
