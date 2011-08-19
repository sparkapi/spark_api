require './spec/spec_helper'

require 'time'

describe OpenHouse do
  subject do
    OpenHouse.new(
      'ResourceUri'=>"/v1/listings/20060412165917817933000000/openhouses/20101127153422574618000000",
      'Id'=>"20060412165917817933000000",
      'Date'=>"10/01/2010",
      'StartTime'=>"09:00:00-07:00",
      'EndTime'=>"12:00:00-07:00"
    )
  end

  it "should respond to a few methods" do
    subject.class.should respond_to(:find_by_listing_key)
  end
  it "should return date and times" do
    start_time = DateTime.new(2010,10,1,9,0,0, "-0700")
    end_time = DateTime.new(2010,10,1,12,0,0, "-0700")
    subject.Date.should eq(Date.new(2010,10,1))
    subject.StartTime.should eq(Time.parse(start_time.to_s))
    subject.EndTime.should eq(Time.parse(end_time.to_s))
  end

  it "should get open house for a listing" do
    stub_auth_request
    stub_api_get('/listings/20060412165917817933000000/openhouses','open_houses.json')
    houses = subject.class.find_by_listing_key('20060412165917817933000000')
    houses.should be_an(Array)
    houses.length.should eq(2)
    houses.first.Id.should eq("20101127153422574618000000")
  end

end
