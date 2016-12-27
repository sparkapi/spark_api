require './spec/spec_helper'

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
        "UnparsedFirstLineAddress"=>"100 Someone's St",
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
        }],
        "OpenHouses" => [{
          'ResourceUri'=>"/v1/listings/20060412165917817933000000/openhouses/20101127153422574618000000",
          'Id'=>"20060412165917817933000000",
          'Date'=>"10/01/2010",
          'StartTime'=>"09:00:00-07:00",
          'EndTime'=>"12:00:00-07:00"
        }],
        "TourOfHomes" => [{
                "AdditionalInfo" => [
                    {"Hosted By" => "Mr. Agent"}, 
                    {"Hosted Phone" => "111-222-3333"}, 
                    {"Area" => "North Fargo"}
                ], 
                "Comments" => "First listing tour", 
                "Date" => "05/14/2012", 
                "Id" => "20120509194700383011000000", 
                "ResourceUri" => "/vX/listings/20000612234839640464000000/tourofhomes/20120509194700383011000000", 
                "StartTime" => "12:00 PM", 
                "EndTime" => "5:00 PM"
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

    describe '.street_address' do
      it 'should return the street address' do
        @listing.street_address.should eq("100 Someone's St")
      end

      it 'should remove data masks' do
        @listing.StandardFields["UnparsedFirstLineAddress"] = "********"
        @listing.street_address.should eq("")
      end

      it 'should handle a missing unparsed first line address' do
        [nil, '', ' '].each do |current|
          @listing.StandardFields['UnparsedFirstLineAddress'] = current
          @listing.street_address.should eq('')
        end
      end
    end

    it "should return the regional address" do
      @listing.region_address.should eq("Fargo, ND 55320")
    end

    it "should return full address" do
      @listing.full_address.should eq("100 Someone's St, Fargo, ND 55320")
    end

    it "should provide shortcut methods to standard fields" do
      @listing.StreetName.should eq("Someone's")
      @listing.YearBuilt.should eq(nil)
      @listing.BuildingAreaTotal.should eq("1321.0")
      @listing.PublicRemarks.should eq(nil)
      @listing.PostalCode.should eq("55320")
      @listing.ListPrice.should eq("100000.0")
    end

    it "should report that it responds to shortcut methods to standard fields" do
      @listing.should respond_to(:StreetName)
      @listing.should respond_to(:YearBuilt)
      @listing.should respond_to(:BuildingAreaTotal)
      @listing.should respond_to(:PublicRemarks)
      @listing.should respond_to(:PostalCode)
      @listing.should respond_to(:ListPrice)

      @listing.should_not respond_to(:BogusField)
      @listing.StandardFields['BogusField'] = 'bogus'
      @listing.should respond_to(:BogusField)
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

    it "should respond to count" do
      Listing.should respond_to(:count)
    end
  end

  describe "URIs" do
    before(:each) do
      stub_auth_request
    end

    context "/listings", :support do
      on_get_it "should return listings" do
        stub_api_get('/listings', 'listings/multiple.json', {:_filter => "PostalCode Eq '83805'"})

        listings = Listing.find(:all, :_filter => "PostalCode Eq '83805'")
        listings.should be_an(Array)
        listings.count.should eq(2)
      end

      on_get_it "should return the count" do
        stub_api_get("/listings", 'count.json', { :_pagination => "count"})
        count = Listing.count()
        count.should == 2001
      end
    end

    context "/listings/<listing_id>", :support do
      on_get_it "should return a listing" do
        stub_api_get("/listings/20060725224713296297000000", 'listings/no_subresources.json')

        l = Listing.find('20060725224713296297000000')
        l.videos.length.should == 0
        l.photos.length.should == 0
        l.documents.length.should == 0
        l.Id.should eq('20060725224713296297000000')
      end

      on_put_it "should save a listing that has modified ListPrice" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/listings/#{list_id}", 'listings/put.json', 'success.json')
        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        l.save.should be(true)
      end

      on_put_it "should save a listing that has modified ExpirationDate" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/listings/#{list_id}", 'listings/put_expiration_date.json', 'success.json')
        l = Listing.find(list_id)
        l.ExpirationDate = "2011-10-04"
        l.save.should be(true)
      end

      it "should not save a listing that does not exist", :method => 'PUT' do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/listings/lolwut", 'listings/put.json') do |request|
          request.to_return(:status => 400, :body => fixture('errors/failure.json'))
        end
        l = Listing.find(list_id)
        l.Id = "lolwut"
        l.ListPrice = 10000.0
        l.save.should be(false)
        expect{ l.save! }.to raise_error(SparkApi::ClientError){ |e| e.status.should == 400 }
      end

      on_put_it "should save a listing with constraints" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/listings/#{list_id}", 'listings/put.json', 'listings/constraints.json')
        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        l.save.should be(true)
        l.constraints.size.should eq(1)
        l.constraints.first.RuleName.should eq("MaxValue")
      end

      on_put_it "should fail saving a listing with constraints and provide the constraints" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/listings/#{list_id}", 'listings/put.json') do |request|
          request.to_return(:status => 400, :body => fixture('errors/failure_with_constraint.json'))
        end

        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        l.save.should be_false
        l.constraints.size.should eq(1)
        l.constraints.first.RuleName.should eq("MaxIncreasePercent")
        l.errors.size.should eq(1)
      end

      on_put_it "should reorder a photo" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/with_photos.json')
        stub_api_put("/listings/#{list_id}/photos/20110826220032167405000000", 'listings/put_reorder_photo.json', 'listings/reorder_photo.json')
        l = Listing.find(list_id)
        l.reorder_photo("20110826220032167405000000", "2")
        l.photos.size.should eq(5)
      end

      on_put_it "should raise an exception when an index is not an Integer" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/with_photos.json')
        stub_api_put("/listings/#{list_id}/photos/2011082622003216740500000", 'listings/put_reorder_photo.json', 'listings/reorder_photo.json')
        l = Listing.find(list_id)
        expect{ l.reorder_photo("2011082622003216740500000", "asdf") }.to raise_error(ArgumentError)
      end

      context "with pagination" do
        # This is really a bogus call, but we should make sure our
        # pagination collection impl still behaves sanely
        on_put_it "should save a listing with constraints" do
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

      context "subresources" do
        on_get_it "should return an array of photos" do
          stub_api_get("/listings/1234", 'listings/with_photos.json', { :_expand => "Photos" })

          l = Listing.find('1234', :_expand => "Photos")
          l.photos.length.should == 5
          l.documents.length.should == 0
          l.videos.length.should == 0
          l.virtual_tours.length.should == 0
        end

        on_get_it "should return an array of documents" do
          stub_api_get("/listings/1234", 'listings/with_documents.json', { :_expand => "Documents" })

          l = Listing.find('1234', :_expand => "Documents")
          l.photos.length.should == 0
          l.documents.length.should == 2
          l.videos.length.should == 0
          l.virtual_tours.length.should == 0
        end

        on_get_it "should return an array of virtual tours" do
          stub_api_get("/listings/1234", 'listings/with_vtour.json', { :_expand => "VirtualTours" })

          l = Listing.find('1234', :_expand => "VirtualTours")
          l.virtual_tours.length.should == 1
          l.photos.length.should == 0
          l.documents.length.should == 0
          l.videos.length.should == 0
        end

        on_get_it "should return an array of videos" do
          stub_api_get("/listings/1234", 'listings/with_videos.json', { :_expand => "Videos" })

          l = Listing.find('1234', :_expand => "Videos")
          l.videos.length.should == 2
          l.virtual_tours.length.should == 0
          l.photos.length.should == 0
          l.documents.length.should == 0
        end

        on_get_it "should return an array of rental calendars" do
          stub_api_get("/listings/1234", 'listings/with_rental_calendar.json', { :_expand => "RentalCalendar" })

          l = Listing.find('1234', :_expand => "RentalCalendar")
          l.rental_calendars.length.should == 2
        end
        
        ## TourOfHomes: Not implemented yet ##
        #on_get_it "should return tour of homes" do
          #stub_api_get("/listings/20060725224713296297000000", 'listings/no_subresources.json')
          #stub_api_get("/listings/20060725224713296297000000/tourofhomes", 'listings/tour_of_homes.json')

          #l = Listing.find('20060725224713296297000000')
          #l.tour_of_homes().length.should == 2
          #l.videos.length.should == 0
          #l.photos.length.should == 0
          #l.documents.length.should == 0
        #end

        on_get_it "should return permissions" do
          stub_api_get("/listings/20060725224713296297000000", 'listings/with_permissions.json', { :_expand => "Permissions" })
          l = Listing.find('20060725224713296297000000', :_expand => "Permissions")
          l.Permissions["Editable"].should eq(true)
          l.editable?().should eq(true)
          l.editable?(:PriceChange).should eq(true)
          l.editable?(:Photos).should eq(false)
        end

        on_delete_it "should bulk delete listing photos" do
          list_id = "20060725224713296297000000"
          stub_api_get("/listings/#{list_id}", 'listings/with_photos.json', { :_expand => "Photos" })
          l = Listing.find(list_id, :_expand => "Photos")
          photo_id1 = l.photos[0].Id
          photo_id2 = l.photos[1].Id
          stub_api_delete("/listings/#{list_id}/photos/#{photo_id1},#{photo_id2}", 'success.json')
          l.batch_photo_delete(photo_id1 + "," + photo_id2)
        end
      end
    end

    context "/my/listings", :support do
      on_get_it "should return my listings" do
        stub_api_get('/my/listings', 'listings/multiple.json')

        listings = Listing.my
        listings.should be_an(Array)
        listings.count.should eq(2)
      end
    end

    context "/office/listings", :support do
      on_get_it "GET should return office listings" do
        stub_api_get('/office/listings', 'listings/multiple.json')

        listings = Listing.office
        listings.should be_an(Array)
        listings.count.should eq(2)
      end
    end

    context "/company/listings", :support do
      on_get_it "should return company listings" do
        stub_api_get('/company/listings', 'listings/multiple.json')

        listings = Listing.company
        listings.should be_an(Array)
        listings.count.should eq(2)
      end
    end

    context "/listings/nearby", :support do
      on_get_it "should return nearby homes" do
        stub_api_get("/listings/nearby",
                     'listings/no_subresources.json', {:_lat => "45.45", :_lon => "-93.98"})
        l = Listing.nearby(45.45, -93.98)
        l.length.should == 1
      end
    end

    context "/listings/tourofhomes", :support do
      on_get_it "should return tours of homes" do
        s = stub_api_get('/listings/tourofhomes', 'listings/tour_of_homes_search.json')

        listings = Listing.tour_of_homes
        
        listings.should be_an(Array)
        listings.count.should eq(2)

      end
    end

  end

  after(:each) do
    @listing = nil
  end

end
