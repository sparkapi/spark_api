require 'spec_helper'

describe SharedLink do

  let(:shared_link) { SharedLink.new(Id: 5) }

  it_behaves_like 'search_container'

  it "returns the right path" do
    expect(shared_link.path).to eq("/sharedlinks")
  end

  describe "create" do
    before(:each) do
      stub_auth_request
    end

    it "creates a shared link for listings" do
      data = { ListingIds: ["5", "6"] }
      stub_api_post("/sharedlinks/listings", data, 'sharedlinks/success.json')
      expect(SharedLink.create(data)).to be_a(SharedLink)
    end

    it "works with string keys" do
      data = { "ListingIds" => ["5", "6"] }
      stub_api_post("/sharedlinks/listings", data, 'sharedlinks/success.json')
      expect(SharedLink.create(data)).to be_a(SharedLink)
    end

    it "creates a shared link for searches" do
      data = { SearchId: "5" }
      stub_api_post("/sharedlinks/search", data, 'sharedlinks/success.json')
      expect(SharedLink.create(data)).to be_a(SharedLink)
    end

    it "creates a shared link for collections" do
      data = { CartId: "5" }
      stub_api_post("/sharedlinks/cart", data, 'sharedlinks/success.json')
      expect(SharedLink.create(data)).to be_a(SharedLink)
    end

    describe "errors" do

      it "returns false if there is an error" do
        data = { ListingIds: ["5", "6"] }
        allow(SparkApi).to receive(:client) { raise SparkApi::BadResourceRequest }
        expect(SharedLink.create(data)).to be false
      end

    end

  end

  describe 'name' do

    it 'returns the name of the referenced listing cart' do
      listing_cart = ListingCart.new(Name: 'the name for the listing cart')
      shared_link.ListingCart = listing_cart
      expect(shared_link.name).to eq listing_cart.Name
    end

    it 'returns the name of the referenced saved search' do
      saved_search = SavedSearch.new({"Id" => "5"*26, "Name" => "My Search"})
      shared_link.SavedSearch = saved_search
      expect(shared_link.name).to eq saved_search.Name
    end

    it 'returns nil if there is no listing cart or saved search' do
      shared_link.SavedSearch = nil
      shared_link.ListingCart = nil
      expect(shared_link.name).to be_nil
    end

    it 'can be set to override the default name' do
      shared_link.name = "my custom name"
      expect(shared_link.name).to eq "my custom name"
    end

  end

  describe 'template' do
  
    it 'returns the template from the saved search' do
      saved_search = SavedSearch.new({"Id" => "5"*26})
      template = QuickSearch.new({"Id" => "8"*26})
      allow(saved_search).to receive(:template).and_return(template)
      shared_link.SavedSearch = saved_search
      expect(shared_link.template).to eq saved_search.template
    end

    it 'returns nil if the shared link is not for a saved search' do
      expect(shared_link.template).to eq nil
    end
  end

  describe 'filter' do
    it 'returns the filter' do
      expect(shared_link.filter).to eq "SharedLink Eq '#{shared_link.id}'"
    end
  end

end
