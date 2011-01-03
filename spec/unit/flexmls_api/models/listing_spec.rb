require './spec/spec_helper'

describe FlexmlsApi::Models::Listing, "Listing model" do
  before(:each) do
    @listing = FlexmlsApi::Models::Listing.new({
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
        "CountyOrParish"=>nil,
        "Photos" => [{
          "Uri300"=>"http=>//images.dev.fbsdata.com/fgo/20101115201631519737000000.jpg",
          "ResourceUri"=>"/v1/listings/20080619000032866372000000/photos/20101115201631519737000000",
          "Name"=>"Designer Entry w/14' Ceilings",
          "Primary"=>true,
          "Id"=>"20101115201631519737000000",
          "Uri800"=>"http=>//devresize.flexmls.com/fgo/800x600/true/20101115201631519737000000-o.jpg",
          "Uri1024"=>"http=>//devresize.flexmls.com/fgo/1024x768/true/20101115201631519737000000-o.jpg",
          "UriLarge"=>"http=>//images.dev.fbsdata.com/fgo/20101115201631519737000000-o.jpg",
          "Caption"=>"apostrophe test for CUR-10508",
          "Uri1280"=>"http=>//devresize.flexmls.com/fgo/1280x1024/true/20101115201631519737000000-o.jpg",
          "UriThumb"=>"http=>//images.dev.fbsdata.com/fgo/20101115201631519737000000-t.jpg",
           "Uri640"=>"http=>//devresize.flexmls.com/fgo/640x480/true/20101115201631519737000000-o.jpg"
        }]
      }, 
      "Id"=>"20080619000032866372000000"
    })

  end

  describe "attributes" do
    it "should allow access to fields" do
      @listing.StandardFields.should be_a Hash
      @listing.StandardFields['ListingId'].should be_a String
      @listing.StandardFields['ListPrice'].should match @listing.ListPrice
      @listing.photos.should be_a Array
    end

    it "should not respond to Photos" do
      @listing.should_not respond_to(:Photos)
    end

  end

  describe "class methods" do
    it "should respond to find" do
      FlexmlsApi::Models::Listing.should respond_to(:find)
    end

    it "should respond to first" do
      FlexmlsApi::Models::Listing.should respond_to(:first)
    end

    it "should respond to last" do
      FlexmlsApi::Models::Listing.should respond_to(:last)
    end

    it "should respond to my" do
      FlexmlsApi::Models::Listing.should respond_to(:my)
    end
    
    it "should respond to find_by_cart_id" do
      FlexmlsApi::Models::Listing.should respond_to(:find_by_cart_id)
    end
  end

  after(:each) do  
    @listing = nil
  end


end
