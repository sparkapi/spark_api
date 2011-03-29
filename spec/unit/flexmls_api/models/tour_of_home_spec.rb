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
    subject.StartTime.should eq(Time.parse(start_time.to_s))
    subject.EndTime.should eq(Time.parse(end_time.to_s))
  end

  it "should get home tours for a listing" do
    stub_auth_request
    stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/20060725224713296297000000/tourofhomes").
    with( :query => {
      :ApiSig => "153446de6d1db765d541587d34ed0fcf",
      :AuthToken => "c401736bf3d3f754f07c04e460e09573",
      :ApiUser => "foobar"
    }).
    to_return(:body => fixture('tour_of_homes.json'))
    v = subject.class.find_by_listing_key('20060725224713296297000000', "foobar")
    v.should be_an(Array)
    v.length.should == 2
  end

end
