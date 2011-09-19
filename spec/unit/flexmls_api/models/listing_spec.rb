describe Listing do
  before(:each) do

    @listing = Listing.new({
      "ResourceUri"=>"/v1/listings/20080619000032866372000000", 
      "StandardFields"=>{
        "StreetNumber"=>"100", 
        "ListingId"=>"07-32", 
        "City"=>"Fargo", 
        "Longitude"=>"", 
        "StreetName"=>"Someone's", 
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
        "StreetSuffix"=>"St", 
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
    
    it "should return the count" do
      stub_auth_request
      stub_api_get("/listings", 'count.json', { :_pagination => "count"})
      count = Listing.count()
      count.should == 2001
    end 
    
  end

  describe "subresources" do
    before do
      stub_auth_request
    end

    it "should return an array of photos" do
      stub_api_get("/listings/1234", 'listings/with_photos.json', { :_expand => "Photos" })
      
      l = Listing.find('1234', :_expand => "Photos")
      l.photos.length.should == 5
      l.documents.length.should == 0
      l.videos.length.should == 0
      l.virtual_tours.length.should == 0
    end

    it "should return an array of documents" do
      stub_api_get("/listings/1234", 'listings/with_documents.json', { :_expand => "Documents" })
      
      l = Listing.find('1234', :_expand => "Documents")
      l.photos.length.should == 0
      l.documents.length.should == 2
      l.videos.length.should == 0
      l.virtual_tours.length.should == 0
    end

    it "should return an array of virtual tours" do
      stub_api_get("/listings/1234", 'listings/with_vtour.json', { :_expand => "VirtualTours" })
      
      l = Listing.find('1234', :_expand => "VirtualTours")
      l.virtual_tours.length.should == 1
      l.photos.length.should == 0
      l.documents.length.should == 0
      l.videos.length.should == 0
    end

    it "should return an array of videos" do
      stub_api_get("/listings/1234", 'listings/with_videos.json', { :_expand => "Videos" })
      
      l = Listing.find('1234', :_expand => "Videos")
      l.videos.length.should == 2
      l.virtual_tours.length.should == 0
      l.photos.length.should == 0
      l.documents.length.should == 0
    end 

    it "should return tour of homes" do
      stub_api_get("/listings/20060725224713296297000000", 'listings/no_subresources.json')
      stub_api_get("/listings/20060725224713296297000000/tourofhomes", 'listings/tour_of_homes.json')

      l = Listing.find('20060725224713296297000000')
      l.tour_of_homes().length.should == 2
      l.videos.length.should == 0
      l.photos.length.should == 0
      l.documents.length.should == 0
    end 

    it "should return street address" do
        @listing.street_address.should eq("100 Someone's St")
    end

    it "should return the regional address" do
        @listing.region_address.should eq("Fargo, ND 55320")
    end

    it "should return full address" do
        @listing.full_address.should eq("100 Someone's St, Fargo, ND 55320")
    end
    
    it "should return permissions" do
      stub_api_get("/listings/20060725224713296297000000", 'listings/with_permissions.json', { :_expand => "Permissions" })
      l = Listing.find('20060725224713296297000000', :_expand => "Permissions")
      l.Permissions["Editable"].should eq(true)
      l.editable?().should eq(true)
      l.editable?(:PriceChange).should eq(true)
      l.editable?(:Photos).should eq(false)
    end 
  end
  
  context "on save" do
    it "should save a listing that has modified" do
      list_id = "20060725224713296297000000"
      stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
      stub_api_put("/listings/#{list_id}", 'listings/put.json', 'success.json')
      l = Listing.find(list_id)
      l.ListPrice = 10000.0
      l.save.should be(true)
    end
    it "should not save a listing that does not exist" do
      list_id = "20060725224713296297000000"
      stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
      stub_api_put("/listings/lolwut", 'listings/put.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end
      l = Listing.find(list_id)
      l.Id = "lolwut"
      l.ListPrice = 10000.0
      l.save.should be(false)
      expect{ l.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
    end
    it "should save a listing with constraints" do
      list_id = "20060725224713296297000000"
      stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
      stub_api_put("/listings/#{list_id}", 'listings/put.json', 'listings/constraints.json')
      l = Listing.find(list_id)
      l.ListPrice = 10000.0
      l.save.should be(true)
      l.constraints.size.should eq(1)
      l.constraints.first.RuleName.should eq("MaxValue")
    end
    context "with pagination" do
      # This is really a bogus call, but we should make sure our pagination collection impl still behaves sanely
      it "should save a listing with constraints" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/listings/#{list_id}", 'listings/put.json', 'listings/constraints_with_pagination.json', :_pagination => '1')
        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        l.save(:_pagination => '1').should be(true)
        l.constraints.size.should eq(1)
        l.constraints.first.RuleName.should eq("MaxValue")
      end
    end
    
  end

  after(:each) do  
    @listing = nil
  end

end
