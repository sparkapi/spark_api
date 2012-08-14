require './spec/spec_helper'

require 'time'

describe TourOfHome do
  subject do
    TourOfHome.new(
      'ResourceUri'=>"/listings/20060725224713296297000000/tourofhomes/20101127153422574618000000",
      'Id'=>"20101127153422574618000000",
      'Date'=>"10/01/2010",
      'StartTime'=>"09:00:00-07:00",
      'EndTime'=>"23:00:00-07:00",
      'Comments'=>"Wonderful home; must see!",
      'AdditionalInfo'=> [{"Hosted By"=>"Joe Smith"}, {"Host Phone"=>"123-456-7890"}, {"Tour Area"=>"North-Central"}]
    )
  end

  it "should respond to a few methods" do
    subject.class.should respond_to(:find_by_listing_key)
  end

  it "should return tour date and times" do
    start_time = DateTime.new(2010,10,1,9,0,0, "-0700")
    end_time = DateTime.new(2010,10,1,23,0,0, "-0700")
    subject.Date.should eq(Date.new(2010,10,1))
# TRYING TO MAKE THIS BACKWARDS COMPATIBLE AND NOT HAPPY ABOUT IT
if RUBY_VERSION < '1.9'
  subject.StartTime.should eq(Time.parse(start_time.to_s))
  subject.EndTime.should eq(Time.parse(end_time.to_s))
else
  subject.StartTime.should eq(start_time.to_time)
  subject.EndTime.should eq(end_time.to_time)
end
  end

  context "/listings/<listing_id>/tourofhomes", :support do
    on_get_it "should get home tours for a listing" do
      stub_auth_request
      stub_api_get('/listings/20060725224713296297000000/tourofhomes','listings/tour_of_homes.json')
      v = subject.class.find_by_listing_key('20060725224713296297000000')
      v.should be_an(Array)
      v.length.should == 2
    end
  end

  context "/listings/<listing_id>/tourofhomes/<tour_id>", :support do
    on_get_it "should get information for a single tour of a home"
  end

end
