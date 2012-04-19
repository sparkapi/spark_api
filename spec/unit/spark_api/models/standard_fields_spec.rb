require './spec/spec_helper'

describe StandardFields do

  before(:each) do
    stub_auth_request
  end

  it "should respond to get" do
    StandardFields.should respond_to(:get)
  end

  it "should find and expand all" do
    StandardFields.should respond_to(:find_and_expand_all)

    # stub request to standardFields
    stub_api_get('/standardfields','standardfields/standardfields.json')

    # stub request for City
    stub_api_get('/standardfields/City','standardfields/city.json')

    # stub request for StateOrProvince
    stub_api_get('/standardfields/StateOrProvince','standardfields/stateorprovince.json')

    # request
    fields = StandardFields.find_and_expand_all(["City","StateOrProvince"])

    # keys are present
    fields.should have_key("City")
    fields.should have_key("StateOrProvince")
    fields.should_not have_key("SubdivisionName")

    # FieldList
    fields["City"]["FieldList"].length.should eq(235)
    fields["StateOrProvince"]["FieldList"].length.should eq(5)

  end

  context "/standardfields/nearby/<property_type>", :support do
    on_get_it "should find nearby fields" do
      StandardFields.should respond_to(:find_nearby)

      # stub request
      stub_api_get('/standardfields/nearby/A','standardfields/nearby.json',
                   :Lat => "50",
                   :Lon => "-92",
                   :_expand => "1")

      # request
      fields = StandardFields.find_nearby(["A"], {:Lat => 50, :Lon => -92})

      # validate response
      fields["D"]["Success"].should eq(true)
      fields["D"]["Results"].first.should have_key("City")
      fields["D"]["Results"].first.should have_key("PostalCode")
      fields["D"]["Results"].first.should have_key("StateOrProvince")
    end
  end

end
