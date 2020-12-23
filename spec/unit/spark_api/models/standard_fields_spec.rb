require './spec/spec_helper'

describe StandardFields do

  before(:each) do
    stub_auth_request
  end

  it "should respond to get" do
    expect(StandardFields).to respond_to(:get)
  end

  it "should find and expand all" do
    expect(StandardFields).to respond_to(:find_and_expand_all)

    # stub request to standardFields
    stub_api_get('/standardfields','standardfields/standardfields.json')

    # stub request for City
    stub_api_get('/standardfields/City','standardfields/city.json')

    # stub request for StateOrProvince
    stub_api_get('/standardfields/StateOrProvince','standardfields/stateorprovince.json')

    # request
    fields = StandardFields.find_and_expand_all(["City","StateOrProvince"])

    # keys are present
    expect(fields).to have_key("City")
    expect(fields).to have_key("StateOrProvince")
    expect(fields).not_to have_key("SubdivisionName")

    # FieldList
    expect(fields["City"]["FieldList"].length).to eq(235)
    expect(fields["StateOrProvince"]["FieldList"].length).to eq(5)

  end

  context "/standardfields/nearby/<property_type>", :support do
    on_get_it "should find nearby fields" do
      expect(StandardFields).to respond_to(:find_nearby)

      # stub request
      stub_api_get('/standardfields/nearby/A','standardfields/nearby.json',
                   :Lat => "50",
                   :Lon => "-92",
                   :_expand => "1")

      # request
      fields = StandardFields.find_nearby(["A"], {:Lat => 50, :Lon => -92})

      # validate response
      expect(fields["D"]["Success"]).to eq(true)
      expect(fields["D"]["Results"].first).to have_key("City")
      expect(fields["D"]["Results"].first).to have_key("PostalCode")
      expect(fields["D"]["Results"].first).to have_key("StateOrProvince")
    end
  end

end
