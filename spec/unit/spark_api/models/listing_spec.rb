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
      expect(@listing.StandardFields).to be_a(Hash)
      expect(@listing.StandardFields['ListingId']).to be_a(String)
      expect(@listing.StandardFields['ListPrice']).to match(@listing.ListPrice)
      expect(@listing.photos).to be_a(Array)
    end

    it "should not respond to removed attributes" do
      expect(@listing).not_to respond_to(:Photos)
      expect(@listing).not_to respond_to(:Documents)
      expect(@listing).not_to respond_to(:VirtualTours)
      expect(@listing).not_to respond_to(:Videos)
    end

    describe '.street_address' do
      it 'should return the street address' do
        expect(@listing.street_address).to eq("100 Someone's St")
      end

      it 'should remove data masks' do
        @listing.StandardFields["UnparsedFirstLineAddress"] = "********"
        expect(@listing.street_address).to eq("")
      end

      it 'should handle a missing unparsed first line address' do
        [nil, '', ' '].each do |current|
          @listing.StandardFields['UnparsedFirstLineAddress'] = current
          expect(@listing.street_address).to eq('')
        end
      end
    end

    it "should return the regional address" do
      expect(@listing.region_address).to eq("Fargo, ND 55320")
    end

    it "should return full address" do
      expect(@listing.full_address).to eq("100 Someone's St, Fargo, ND 55320")
    end

    it "should provide shortcut methods to standard fields" do
      expect(@listing.StreetName).to eq("Someone's")
      expect(@listing.YearBuilt).to eq(nil)
      expect(@listing.BuildingAreaTotal).to eq("1321.0")
      expect(@listing.PublicRemarks).to eq(nil)
      expect(@listing.PostalCode).to eq("55320")
      expect(@listing.ListPrice).to eq("100000.0")
    end

    it "should report that it responds to shortcut methods to standard fields" do
      expect(@listing).to respond_to(:StreetName)
      expect(@listing).to respond_to(:YearBuilt)
      expect(@listing).to respond_to(:BuildingAreaTotal)
      expect(@listing).to respond_to(:PublicRemarks)
      expect(@listing).to respond_to(:PostalCode)
      expect(@listing).to respond_to(:ListPrice)

      expect(@listing).not_to respond_to(:BogusField)
      @listing.StandardFields['BogusField'] = 'bogus'
      expect(@listing).to respond_to(:BogusField)
    end
  end

  describe "class methods" do
    it "should respond to find" do
      expect(Listing).to respond_to(:find)
    end

    it "should respond to first" do
      expect(Listing).to respond_to(:first)
    end

    it "should respond to last" do
      expect(Listing).to respond_to(:last)
    end

    it "should respond to my" do
      expect(Listing).to respond_to(:my)
    end

    it "should respond to find_by_cart_id" do
      expect(Listing).to respond_to(:find_by_cart_id)
    end

    it "should respond to count" do
      expect(Listing).to respond_to(:count)
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
        expect(listings).to be_an(Array)
        expect(listings.count).to eq(2)
      end

      on_get_it "should return the count" do
        stub_api_get("/listings", 'count.json', { :_pagination => "count"})
        count = Listing.count()
        expect(count).to eq(2001)
      end
    end

    context "/listings/<listing_id>", :support do
      on_get_it "should return a listing" do
        stub_api_get("/listings/20060725224713296297000000", 'listings/no_subresources.json')

        l = Listing.find('20060725224713296297000000')
        expect(l.videos.length).to eq(0)
        expect(l.photos.length).to eq(0)
        expect(l.documents.length).to eq(0)
        expect(l.Id).to eq('20060725224713296297000000')
      end

      on_put_it "should save a listing that has modified ListPrice" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/flexmls/listings/#{list_id}", 'listings/put.json', 'success.json')
        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        expect(l.save).to be(true)
      end

      on_put_it "should save a listing that has modified ExpirationDate" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/flexmls/listings/#{list_id}", 'listings/put_expiration_date.json', 'success.json')
        l = Listing.find(list_id)
        l.ExpirationDate = "2011-10-04"
        expect(l.save).to be(true)
      end

      it "should not save a listing that does not exist", :method => 'PUT' do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/flexmls/listings/lolwut", 'listings/put.json') do |request|
          request.to_return(:status => 400, :body => fixture('errors/failure.json'))
        end
        l = Listing.find(list_id)
        l.Id = "lolwut"
        l.ListPrice = 10000.0
        expect(l.save).to be(false)
        expect{ l.save! }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(400) }
      end

      on_put_it "should save a listing with constraints" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/flexmls/listings/#{list_id}", 'listings/put.json', 'listings/constraints.json')
        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        expect(l.save).to be(true)
        expect(l.constraints.size).to eq(1)
        expect(l.constraints.first.RuleName).to eq("MaxValue")
      end

      on_put_it "should fail saving a listing with constraints and provide the constraints" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/no_subresources.json')
        stub_api_put("/flexmls/listings/#{list_id}", 'listings/put.json') do |request|
          request.to_return(:status => 400, :body => fixture('errors/failure_with_constraint.json'))
        end

        l = Listing.find(list_id)
        l.ListPrice = 10000.0
        expect(l.save).to be false
        expect(l.constraints.size).to eq(1)
        expect(l.constraints.first.RuleName).to eq("MaxIncreasePercent")
        expect(l.errors.size).to eq(1)
      end

      on_put_it "should reorder a photo" do
        list_id = "20060725224713296297000000"
        stub_api_get("/listings/#{list_id}", 'listings/with_photos.json')
        stub_api_put("/listings/#{list_id}/photos/20110826220032167405000000", 'listings/put_reorder_photo.json', 'listings/reorder_photo.json')
        l = Listing.find(list_id)
        l.reorder_photo("20110826220032167405000000", "2")
        expect(l.photos.size).to eq(5)
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
          stub_api_put("/flexmls/listings/#{list_id}", 'listings/put.json', 'listings/constraints_with_pagination.json', :_pagination => '1')
          l = Listing.find(list_id)
          l.ListPrice = 10000.0
          expect(l.save(:_pagination => '1')).to be(true)
          expect(l.constraints.size).to eq(1)
          expect(l.constraints.first.RuleName).to eq("MaxValue")
        end
      end

      context "subresources" do
        on_get_it "should return an array of photos" do
          stub_api_get("/listings/1234", 'listings/with_photos.json', { :_expand => "Photos" })

          l = Listing.find('1234', :_expand => "Photos")
          expect(l.photos.length).to eq(5)
          expect(l.documents.length).to eq(0)
          expect(l.videos.length).to eq(0)
          expect(l.virtual_tours.length).to eq(0)
        end

        on_get_it "should return an array of documents" do
          stub_api_get("/listings/1234", 'listings/with_documents.json', { :_expand => "Documents" })

          l = Listing.find('1234', :_expand => "Documents")
          expect(l.photos.length).to eq(0)
          expect(l.documents.length).to eq(2)
          expect(l.videos.length).to eq(0)
          expect(l.virtual_tours.length).to eq(0)
        end

        on_get_it "should return an array of virtual tours" do
          stub_api_get("/listings/1234", 'listings/with_vtour.json', { :_expand => "VirtualTours" })

          l = Listing.find('1234', :_expand => "VirtualTours")
          expect(l.virtual_tours.length).to eq(1)
          expect(l.photos.length).to eq(0)
          expect(l.documents.length).to eq(0)
          expect(l.videos.length).to eq(0)
        end

        on_get_it "should return an array of videos" do
          stub_api_get("/listings/1234", 'listings/with_videos.json', { :_expand => "Videos" })

          l = Listing.find('1234', :_expand => "Videos")
          expect(l.videos.length).to eq(2)
          expect(l.virtual_tours.length).to eq(0)
          expect(l.photos.length).to eq(0)
          expect(l.documents.length).to eq(0)
        end

        on_get_it "should return an array of rental calendars" do
          stub_api_get("/listings/1234", 'listings/with_rental_calendar.json', { :_expand => "RentalCalendar" })

          l = Listing.find('1234', :_expand => "RentalCalendar")
          expect(l.rental_calendars.length).to eq(2)
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
          expect(l.Permissions["Editable"]).to eq(true)
          expect(l.editable?()).to eq(true)
          expect(l.editable?(:PriceChange)).to eq(true)
          expect(l.editable?(:Photos)).to eq(false)
        end

        on_delete_it "should bulk delete listing photos" do
          list_id = "20060725224713296297000000"
          stub_api_get("/listings/#{list_id}", 'listings/with_photos.json', { :_expand => "Photos" })
          l = Listing.find(list_id, :_expand => "Photos")
          photo_id1 = l.photos[0].Id
          photo_id2 = l.photos[1].Id
          stub_api_delete("/listings/#{list_id}/photos/#{photo_id1},#{photo_id2}", 'listings/photos/index.json')
          expect(l.delete_photos(photo_id1 + "," + photo_id2)).not_to be_empty
        end
      end
    end

    context "/my/listings", :support do
      on_get_it "should return my listings" do
        stub_api_get('/my/listings', 'listings/multiple.json')

        listings = Listing.my
        expect(listings).to be_an(Array)
        expect(listings.count).to eq(2)
      end
    end

    context "/office/listings", :support do
      on_get_it "GET should return office listings" do
        stub_api_get('/office/listings', 'listings/multiple.json')

        listings = Listing.office
        expect(listings).to be_an(Array)
        expect(listings.count).to eq(2)
      end
    end

    context "/company/listings", :support do
      on_get_it "should return company listings" do
        stub_api_get('/company/listings', 'listings/multiple.json')

        listings = Listing.company
        expect(listings).to be_an(Array)
        expect(listings.count).to eq(2)
      end
    end

    context "/listings/nearby", :support do
      on_get_it "should return nearby homes" do
        stub_api_get("/listings/nearby",
                     'listings/no_subresources.json', {:_lat => "45.45", :_lon => "-93.98"})
        l = Listing.nearby(45.45, -93.98)
        expect(l.length).to eq(1)
      end
    end

    context "/listings/tourofhomes", :support do
      on_get_it "should return tours of homes" do
        s = stub_api_get('/listings/tourofhomes', 'listings/tour_of_homes_search.json')

        listings = Listing.tour_of_homes
        
        expect(listings).to be_an(Array)
        expect(listings.count).to eq(2)

      end
    end

  end

  after(:each) do
    @listing = nil
  end

end
