require './spec/spec_helper'

describe RentalCalendar do

  describe "/listings/<listing_id>/rentalcalendar", :support do
    before do
      stub_auth_request
      stub_api_get('/listings/1234/rentalcalendar','listings/rental_calendar.json')
    end

    on_get_it "should get an array of rental calendars" do
      p = RentalCalendar.find_by_listing_key('1234')
      expect(p).to be_an(Array)
      expect(p.length).to eq(2)
    end

  end
  
  describe "test include_date method" do
    cal = RentalCalendar.new
    cal.StartDate = Date.parse("2012-07-12")
    cal.EndDate = Date.parse("2012-07-18")
    cal.include_date?(Date.parse("2012-06-01")).should == false
    cal.include_date?(Date.parse("2012-07-12")).should == true
    cal.include_date?(Date.parse("2012-07-15")).should == true
    cal.include_date?(Date.parse("2012-07-18")).should == true
    cal.include_date?(Date.parse("2012-08-01")).should == false
  end

end