require './spec/spec_helper'

describe ListingCart do
  before(:each) do
    stub_auth_request
  end

  context "/listingcarts", :support do
    on_get_it "should get all listing carts" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resources = subject.class.get
      expect(resources).to be_an(Array)
      expect(resources.length).to eq(2)
      expect(resources.first.Id).to eq("20100912153422758914000000")
    end

    on_post_it "should save a new listing cart" do
      stub_api_post("/#{subject.class.element_name}", 'listing_carts/new.json', 'listing_carts/post.json')
      subject.ListingIds = ['20110112234857732941000000',
                            '20110302120238448431000000',
                            '20110510011212354751000000']
      subject.Name = "My Cart's Name"
      expect(subject.save).to be(true)
      expect(subject.ResourceUri).to eq("/v1/listingcarts/20100912153422758914000000")
    end

    on_post_it "should fail saving" do
      stub_api_post("/#{subject.class.element_name}",'listing_carts/empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end
      subject
      expect(subject.save).to be(false)
      expect{ subject.save! }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(400) }
    end
  end

  context "/listingcarts/<cart_id>", :support do
    on_get_it "should get a listing cart" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      expect(resource.Id).to eq("20100912153422758914000000")
      expect(resource.Name).to eq("My Listing Cart")
      expect(resource.ListingCount).to eq(10)
    end

    on_put_it "should save a listing cart Name" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      stub_api_put("/#{subject.class.element_name}/#{resource.Id}", 'listing_carts/put_name.json', 'success.json')
      resource.Name = "My Cart's Name"
      expect(resource.changed?).to be(true)
      expect(resource.save).to be(true)
      expect(resource.ResourceUri).to eq("/v1/listingcarts/20100912153422758914000000")
    end

    on_put_it "should save a listing cart ListingIds" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      stub_api_put("/#{subject.class.element_name}/#{resource.Id}", 'listing_carts/put_ids.json', 'success.json')
      resource.ListingIds = ['20110112234857732941000000',
                             '20110302120238448431000000',
                             '20110510011212354751000000']
      expect(resource.changed?).to be(true)
      expect(resource.save).to be(true)
      expect(resource.ResourceUri).to eq("/v1/listingcarts/20100912153422758914000000")
    end

    on_post_it "should add a listing to a cart" do
      list_id = "20110621133454434543000000"
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      expect(resource.Id).to eq("20100912153422758914000000")
      stub_api_post("/#{subject.class.element_name}/#{resource.Id}",'listing_carts/add_listing_post.json', 'listing_carts/add_listing.json')
      expect(resource.ListingCount).to eq(10)
      resource.add_listing(list_id)
      expect(resource.ListingCount).to eq(11)
    end

    on_post_it "should add multiple listings to a cart" do
      listing_ids = ["20110621133454434543000000", "20110621133454434543000001"]
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      expect(resource.Id).to eq("20100912153422758914000000")
      stub_api_post("/#{subject.class.element_name}/#{resource.Id}",'listing_carts/add_listings_post.json', 'listing_carts/add_listings.json')
      expect(resource.ListingCount).to eq(10)
      resource.add_listings(listing_ids)
      expect(resource.ListingCount).to eq(12)
    end

    on_delete_it "should delete a listing cart" do
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      expect(resource.Id).to eq("20100912153422758914000000")
      expect(resource.Name).to eq("My Listing Cart")
      expect(resource.ListingCount).to eq(10)
      stub_api_delete("/#{subject.class.element_name}/#{resource.Id}", 'success.json')
      expect(resource.delete).to be(true)
    end
  end

  context "/listingcarts/<cart_id>/listings/<listing_id>", :support do
    on_delete_it "should remove a listing from a cart" do
      list_id = "20110621133454434543000000"
      stub_api_get("/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resource = subject.class.get.first
      expect(resource.Id).to eq("20100912153422758914000000")
      stub_api_delete("/#{subject.class.element_name}/#{resource.Id}/listings/#{list_id}", 'listing_carts/remove_listing.json')
      expect(resource.ListingCount).to eq(10)
      resource.remove_listing(list_id)
      expect(resource.ListingCount).to eq(9)
    end
  end

  context "/listingcarts/for/<listing_id>", :support do
    let(:listing){ Listing.new(:Id => "20110112234857732941000000") }
    on_get_it "should get all carts for a listing" do
      stub_api_get("/#{subject.class.element_name}/for/#{listing.Id}", 'listing_carts/listing_cart.json')
      [listing, listing.Id ].each do |l|
        resources = subject.class.for(l)
        expect(resources).to be_an(Array)
        expect(resources.length).to eq(2)
        expect(resources.first.Id).to eq("20100912153422758914000000")
      end
    end
  end

  context "/my/listingcarts", :support do
    on_get_it "should get the carts for a user" do
      stub_api_get("/my/#{subject.class.element_name}", 'listing_carts/listing_cart.json')
      resources = subject.class.my
      expect(resources).to be_an(Array)
      expect(resources.length).to eq(2)
      expect(resources.first.Id).to eq("20100912153422758914000000")
    end
  end

  context "/listingcarts/portal", :support do
    on_get_it "should get the carts specific to a portal user" do
      stub_api_get("/#{subject.class.element_name}/portal", 'listing_carts/listing_cart.json')
      resources = subject.class.portal
      expect(resources).to be_an(Array)
      expect(resources.length).to eq(2)
      expect(resources.first.Id).to eq("20100912153422758914000000")
    end
  end

  describe "#listings" do 
    it "should return the listings in the cart" do 
      resource = subject.class.new Id: 5, ListingIds: ["1234"]
      stub_api_get("/#{subject.class.element_name}/#{resource.Id}/listings", 'listings/multiple.json')
      expect(resource.listings).to be_a(Array)
      expect(resource.listings.first).to be_a(Listing)
    end

    it "should return an empty array if there aren't any listings" do 
      resource = subject.class.new Id: 5
      expect(resource.listings).to be_a(Array)
      expect(resource.listings.count).to be === 0
    end
  end

  describe "filter" do
    it "should return a filter string for the cart" do
      resource = subject.class.new Id: 5
      expect(resource.filter).to eq("ListingCart Eq '5'")
    end
  end

  describe "#deletable?" do
    it "should return true for private custom carts" do
      resource = subject.class.new
      expect(resource.deletable?).to be true
    end
    
    it "should return true for custom vow carts" do
      resource = subject.class.new PortalCartType: "Custom"
      expect(resource.deletable?).to be true
    end

    it "should return false for vow carts" do
      resource = subject.class.new PortalCartType: "Favorites"
      expect(resource.deletable?).to be false
    end
  end

end
