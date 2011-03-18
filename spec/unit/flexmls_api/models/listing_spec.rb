require './spec/spec_helper'

describe Listing do
  before(:each) do
    @listing = Listing.new({
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
      @listing.StandardFields.should be_a(Hash)
      @listing.StandardFields['ListingId'].should be_a(String)
      @listing.StandardFields['ListPrice'].should match(@listing.ListPrice)
      @listing.photos.should be_a(Array)
    end

    it "should not respond to removed attributes" do
      @listing.should_not respond_to(:Photos)
      @listing.should_not respond_to(:Documents)
      @listing.should_not respond_to(:VirtualTours)
      @listing.should_not respond_to(:Videos)
    end

  end

  describe "class methods" do
    it "should respond to find" do
      Listing.should respond_to(:find)
    end

    it "should respond to first" do
      Listing.should respond_to(:first)
    end

    it "should respond to last" do
      Listing.should respond_to(:last)
    end

    it "should respond to my" do
      Listing.should respond_to(:my)
    end
    
    it "should respond to find_by_cart_id" do
      Listing.should respond_to(:find_by_cart_id)
    end
  end

  describe "subresources" do
    before do
      stub_auth_request
    end


    it "should return an array of photos" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234").
          with(:query => {
            :ApiSig => "3c942a2d6746299c476dd2e30d10966b",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573",
            :ApiUser => "foobar",
            :_expand => "Photos"
          }).
          to_return(:body => fixture('listing_with_photos.json'))
      
      l = Listing.find('1234', :ApiUser => "foobar", :_expand => "Photos")
      l.photos.length.should == 5
      l.documents.length.should == 0
      l.videos.length.should == 0
      l.virtual_tours.length.should == 0
    end

    it "should return an array of documents" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234").
          with(:query => {
            :ApiSig => "554b6e2a3efec8719b782647c19d238d",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573",
            :ApiUser => "foobar",
            :_expand => "Documents"
          }).
          to_return(:body => fixture('listing_with_documents.json'))
      
      l = Listing.find('1234', :ApiUser => "foobar", :_expand => "Documents")
      l.photos.length.should == 0
      l.documents.length.should == 2
      l.videos.length.should == 0
      l.virtual_tours.length.should == 0
    end

    it "should return an array of virtual tours" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234").
          with(:query => {
            :ApiSig => "cc966b538640dd6b37dce0067cea2e5a",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573",
            :ApiUser => "foobar",
            :_expand => "VirtualTours"
          }).
          to_return(:body => fixture('listing_with_vtour.json'))
      
      l = Listing.find('1234', :ApiUser => "foobar", :_expand => "VirtualTours")
      l.virtual_tours.length.should == 1
      l.photos.length.should == 0
      l.documents.length.should == 0
      l.videos.length.should == 0
    end


    it "should return an array of videos" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234").
          with(:query => {
            :ApiSig => "12afd7ef1d98ca35c613040f5ddb92b2",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573",
            :ApiUser => "foobar",
            :_expand => "Videos"
          }).
          to_return(:body => fixture('listing_with_videos.json'))
      
      l = Listing.find('1234', :ApiUser => "foobar", :_expand => "Videos")
      l.videos.length.should == 2
      l.virtual_tours.length.should == 0
      l.photos.length.should == 0
      l.documents.length.should == 0
    end 

    it "should return tour of homes" do
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/20060725224713296297000000").
        with(:query => {
          :ApiSig => "b3ae2bec3500ba4620bf8224dee28d20",
          :AuthToken => "c401736bf3d3f754f07c04e460e09573",
          :ApiUser => "foobar"
        }).
        to_return(:body => fixture('listing_no_subresources.json'))
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/20060725224713296297000000/tourofhomes").
        with( :query => {
          :ApiSig => "153446de6d1db765d541587d34ed0fcf",
          :AuthToken => "c401736bf3d3f754f07c04e460e09573",
          :ApiUser => "foobar"
        }).
        to_return(:body => fixture('tour_of_homes.json'))
          
      l = Listing.find('20060725224713296297000000', :ApiUser => "foobar")
      l.tour_of_homes("foobar").length.should == 2
      l.videos.length.should == 0
      l.photos.length.should == 0
      l.documents.length.should == 0
    end 
    

  end

  after(:each) do  
    @listing = nil
  end


end
