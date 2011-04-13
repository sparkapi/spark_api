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
    stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/standardfields").
      with(:query => {
        :ApiSig => "e8c27a6d4b96ed4267776581917bc9ef",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573",
        :ApiUser => "foobar"
      }).
      to_return(:body => fixture('standardfields.json'))
    
    # stub request for City
    stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/standardfields/City").
      with(:query => {
        :ApiSig => "447045bf65019ed960ee16ba64311e7f",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573",
        :ApiUser => "foobar"
      }).
      to_return(:body => fixture('standardfields_city.json'))
    
    # stub request for StateOrProvince
    stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/standardfields/StateOrProvince").
      with(:query => {
        :ApiSig => "2828f29a5c68978cb29e6048d0f82a31",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573",
        :ApiUser => "foobar"
      }).
      to_return(:body => fixture('standardfields_stateorprovince.json'))
    
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
  
  
  it "should find nearby fields" do
    StandardFields.should respond_to(:find_nearby)
    
    # stub request
    stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/standardfields/nearby/A").
      with(:query => {
        :ApiSig => "0601ee6e972659098318721a3c0ecb00",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573",
        :ApiUser => "foobar",
        :Lat => "50",
        :Lon => "-92",
        :_expand => "1"
      }).
      to_return(:body => fixture('standardfields_nearby.json'))
    
    # request
    fields = StandardFields.find_nearby(["A"], {:Lat => 50, :Lon => -92})
    
    # validate response
    fields["D"]["Success"].should eq(true)
    fields["D"]["Results"].first.should have_key("City")
    fields["D"]["Results"].first.should have_key("PostalCode")
    fields["D"]["Results"].first.should have_key("StateOrProvince")

  end
  
end