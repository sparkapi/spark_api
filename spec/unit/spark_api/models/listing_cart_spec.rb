require './spec/spec_helper'

describe ListingCart do
  before(:each) do
    stub_auth_request
  end

  context "/listingcarts", :support do
    on_get_it "should get all listing carts" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resources = subject.class.get
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq("20100912153422758914000000")
    end

    on_post_it "should save a new listing cart" do
      stub_api_post("/#{subject.class.element_name}", 'listing_carts/new.json', 'listing_carts/post.json')
      subject.ListingIds = ['20110112234857732941000000',
                            '20110302120238448431000000',
                            '20110510011212354751000000']
      subject.Name = "My Cart's Name"
      subject.save.should be(true)
      subject.ResourceUri.should eq("/v1/listingcarts/20100912153422758914000000")
    end

    on_post_it "should fail saving" do
      stub_api_post("/#{subject.class.element_name}",'listing_carts/empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end
      subject
      subject.save.should be(false)
      expect{ subject.save! }.to raise_error(SparkApi::ClientError){ |e| e.status.should == 400 }
    end
  end

  context "/listingcarts/<cart_id>", :support do
    on_get_it "should get a listing cart" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      resource.Id.should eq("20100912153422758914000000")
      resource.Name.should eq("My Listing Cart")
      resource.ListingCount.should eq(10)
    end

    on_put_it "should save a listing cart" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      stub_api_put("/#{subject.class.element_name}/#{resource.Id}", 'listing_carts/new.json', 'success.json')
      resource.Name = "My Cart's Name"
      resource.ListingIds = ['20110112234857732941000000',
                             '20110302120238448431000000',
                             '20110510011212354751000000']
      resource.save.should be(true)
      resource.ResourceUri.should eq("/v1/listingcarts/20100912153422758914000000")
    end

    on_post_it "should add a listing to a cart" do
      list_id = "20110621133454434543000000"
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      resource.Id.should eq("20100912153422758914000000")
      stub_api_post("/#{subject.class.element_name}/#{resource.Id}",'listing_carts/add_listing_post.json', 'listing_carts/add_listing.json')
      resource.ListingCount.should eq(10)
      resource.add_listing(list_id)
      resource.ListingCount.should eq(11)
    end

    on_delete_it "should delete a listing cart" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      resource.Id.should eq("20100912153422758914000000")
      resource.Name.should eq("My Listing Cart")
      resource.ListingCount.should eq(10)
      stub_api_delete("/#{subject.class.element_name}/#{resource.Id}", 'success.json')
      resource.delete.empty?.should be(true)
    end
  end

  context "/listingcarts/<cart_id>/listings/<listing_id>", :support do
    on_delete_it "should remove a listing from a cart" do
      list_id = "20110621133454434543000000"
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      resource.Id.should eq("20100912153422758914000000")
      stub_api_delete("/#{subject.class.element_name}/#{resource.Id}/listings/#{list_id}", 'listing_carts/remove_listing.json')
      resource.ListingCount.should eq(10)
      resource.remove_listing(list_id)
      resource.ListingCount.should eq(9)
    end
  end

  context "/listingcarts/for/<listing_id>", :support do
    let(:listing){ Listing.new(:Id => "20110112234857732941000000") }
    on_get_it "should get all carts for a listing" do
      stub_api_get("/#{subject.class.element_name}/for/#{listing.Id}", 'listing_carts/listing_cart.json')
      [listing, listing.Id ].each do |l|
        resources = subject.class.for(l)
        resources.should be_an(Array)
        resources.length.should eq(2)
        resources.first.Id.should eq("20100912153422758914000000")
      end
    end
  end

  context "/my/listingcarts", :support do
    on_get_it "should get the carts for a user" do
      stub_api_get("/my/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resources = subject.class.my
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq("20100912153422758914000000")
    end
  end

  context "/listingcarts/portal", :support do
    on_get_it "should get the carts specific to a portal user" do
      stub_api_get("/#{subject.class.element_name}/portal", 'listing_carts/listing_cart.json')
      resources = subject.class.portal
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq("20100912153422758914000000")
    end
  end

end
