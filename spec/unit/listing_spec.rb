require 'flexmls_api'

describe FlexmlsApi::Listing, "Listing model" do
  before(:each) do
    @listing = FlexmlsApi::Listing.new({
      "ResourceUri"=>"/v1/listings/20080619000032866372000000", 
      "StandardFields"=>{
        "StreetNumber"=>"********", 
        "ListingId"=>"07-32", 
        "City"=>"Fargo", 
        "Longitude"=>"", 
        "StreetName"=>"********", 
        "YearBuilt"=>nil, 
        "BuildingAreaTotal"=>"1321.0", 
        "PublicRemarks"=>nil, 
        "PostalCode"=>"55320", 
        "ListPrice"=>"100000.0", 
        "BathsThreeQuarter"=>nil, 
        "Latitude"=>"", 
        "StreetDirPrefix"=>nil, 
        "StreetAdditionalInfo"=>"********", 
        "PropertyType"=>"A", 
        "StateOrProvince"=>"ND", 
        "BathsTotal"=>"0.0", 
        "BathsFull"=>nil, 
        "ListingKey"=>"20080619000032866372000000", 
        "StreetDirSuffix"=>"********", 
        "BedsTotal"=>2, 
        "ModificationTimestamp"=>"2010-11-22T23:36:42Z", 
        "BathsHalf"=>nil, 
        "CountyOrParish"=>nil
      }, 
      "Id"=>"20080619000032866372000000"
    })

  end

  describe "attributes" do
    it "should allow access to fields" do
      @listing.StandardFields.should be_a Hash
      @listing.StandardFields['ListingId'].should be_a String
      @listing.StandardFields['ListPrice'].should match @listing.ListPrice
    end
  end

  describe "responds to" do
    it "should respond to find" do
      FlexmlsApi::Listing.respond_to?(:find)
    end

    it "should respond to first" do
      FlexmlsApi::Listing.respond_to?(:first)
    end

    it "should respond to last" do
      FlexmlsApi::Listing.respond_to?(:last)
    end

  end

  after(:each) do  
    @listing = nil
  end


end
