require './spec/spec_helper'

describe ListingCart do

  it "should get all listing carts" do
    stub_api_get("/#{subject.class.element_name}", 'listing_cart.json')
    resources = subject.class.get
    resources.should be_an(Array)
    resources.length.should eq(2)
    resources.first.Id.should eq("20100912153422758914000000")
  end

  it "should get a listing cart" do
    stub_api_get("/#{subject.class.element_name}", 'listing_cart.json')
    resource = subject.class.get.first
    resource.Id.should eq("20100912153422758914000000")
    resource.Name.should eq("My Listing Cart")
    resource.ListingCount.should eq(10)
  end
  
  it "should remove a listing from a cart" do
    list_id = "20110621133454434543000000"
    stub_api_get("/#{subject.class.element_name}", 'listing_cart.json')
    resource = subject.class.get.first
    resource.Id.should eq("20100912153422758914000000")
    stub_api_delete("/#{subject.class.element_name}/#{resource.Id}/listings/#{list_id}", 'listing_cart_remove_listing.json')
    resource.ListingCount.should eq(10)
    resource.remove_listing(list_id)
    resource.ListingCount.should eq(9)
  end

  let(:listing){ Listing.new(:Id => "20110112234857732941000000") }
  it "should get all carts for a listing" do
    stub_api_get("/#{subject.class.element_name}/for/#{listing.Id}", 'listing_cart.json')
    [listing, listing.Id ].each do |l|
    resources = subject.class.for(l)
    resources.should be_an(Array)
    resources.length.should eq(2)
    resources.first.Id.should eq("20100912153422758914000000")
    end
  end
  
  it "should save a new listing cart" do
    stub_api_post("/#{subject.class.element_name}", 'listing_cart_new.json', 'listing_cart_post.json')
    subject.ListingIds = [
      '20110112234857732941000000',
      '20110302120238448431000000',
      '20110510011212354751000000']
    subject.Name = "My Cart's Name"
    subject.save.should be(true)
    subject.ResourceUri.should eq("/v1/listingcarts/20100912153422758914000000")
  end

  it "should save a listing cart" do
    stub_api_get("/#{subject.class.element_name}", 'listing_cart.json')
    resource = subject.class.get.first
    stub_api_put("/#{subject.class.element_name}/#{resource.Id}", 'listing_cart_new.json', 'success.json')
    resource.ListingIds = [
      '20110112234857732941000000',
      '20110302120238448431000000',
      '20110510011212354751000000']
    
    resource.Name = "My Cart's Name"
    resource.save.should be(true)
    resource.ResourceUri.should eq("/v1/listingcarts/20100912153422758914000000")
  end
  
  it "should fail saving" do
    stub_api_post("/#{subject.class.element_name}",'listing_cart_empty.json') do |request|
      request.to_return(:status => 400, :body => fixture('errors/failure.json'))
    end
    subject
    subject.save.should be(false)
    expect{ subject.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end

  it "should delete a listing cart" do
    stub_api_get("/#{subject.class.element_name}", 'listing_cart.json')
    resource = subject.class.get.first
    resource.Id.should eq("20100912153422758914000000")
    resource.Name.should eq("My Listing Cart")
    resource.ListingCount.should eq(10)
    stub_api_delete("/#{subject.class.element_name}/#{resource.Id}", 'success.json')
    resource.delete.should be(nil)
  end

end
