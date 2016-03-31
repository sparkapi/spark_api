require './spec/spec_helper'

describe SavedSearch do

  before(:each) do
    stub_auth_request
  end

  let(:id){ "20100815220615294367000000" }

  context "/savedsearches", :support do

    on_get_it "should get all SavedSearches" do
      stub_api_get("/#{subject.class.element_name}", 'saved_searches/get.json')
      resources = subject.class.get
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq(id)
    end

    on_post_it "should create a saved search" do
      stub_api_post("/#{subject.class.element_name}", "saved_searches/new.json", "saved_searches/post.json")
      resource = SavedSearch.new({ :Name => "A new search name here" })
      resource.should respond_to(:save)
      resource.save
      resource.persisted?.should eq(true)
      resource.attributes['Id'].should eq("20100815220615294367000000")
      resource.attributes['ResourceUri'].should eq("/v1/savedsearches/20100815220615294367000000")
    end

  end

  context "/savedsearches/<search_id>", :support do

    on_get_it "should get a SavedSearch" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      resource = subject.class.find(id)
      resource.Id.should eq(id)
      resource.Name.should eq("Search name here")
    end

    on_put_it "should update a SavedSearch" do
      stub_api_get("/#{subject.class.element_name}/#{id}", "saved_searches/get.json")
      stub_api_put("/#{subject.class.element_name}/#{id}", "saved_searches/update.json", "saved_searches/post.json")
      resource = subject.class.find(id)
      resource.should respond_to(:save)
      resource.Name = "A new search name here"
      resource.save
    end

    on_delete_it "should delete a saved search" do
      stub_api_get("/#{subject.class.element_name}/#{id}", "saved_searches/get.json")
      stub_api_delete("/#{subject.class.element_name}/#{id}", "generic_delete.json")
      resource = subject.class.find(id)
      resource.should respond_to(:delete)
      resource.delete
    end

    it "should attach a contact by id" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_put("/#{subject.class.element_name}/#{id}/contacts/20101230223226074306000000", nil, "success.json")
      resource = subject.class.find(id)
      resource.attach("20101230223226074306000000")
      resource.ContactIds.size.should eq(2)
      resource.ContactIds.any? { |c| c == "20101230223226074306000000" }.should eq(true)
    end

    it "should detach a contact by id" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_delete("/#{subject.class.element_name}/#{id}/contacts/20100815220615294367000000", "generic_delete.json")
      resource = subject.class.find(id)
      resource.detach("20100815220615294367000000")
      resource.ContactIds.size.should eq(0)
    end

    it "should attach a contact by Contact object" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_put("/#{subject.class.element_name}/#{id}/contacts/20101230223226074306000000", nil, "success.json")
      resource = subject.class.find(id)
      resource.attach(Contact.new({ :Id => "20101230223226074306000000" }))
      resource.ContactIds.size.should eq(2)
      resource.ContactIds.any? { |c| c == "20101230223226074306000000" }.should eq(true)
    end

    it "should detach a contact by Contact object" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_delete("/#{subject.class.element_name}/#{id}/contacts/20100815220615294367000000", "generic_delete.json")
      resource = subject.class.find(id)
      resource.detach(Contact.new({:Id => "20100815220615294367000000" }))
      resource.ContactIds.size.should eq(0)
    end
    
    it "should initialize ContactIds as an array if nil" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_delete("/#{subject.class.element_name}/#{id}/contacts/20100815220615294367000000", "generic_delete.json")
      resource = subject.class.find(id)
      resource.ContactIds = nil
      resource.detach(Contact.new({:Id => "20100815220615294367000000" }))
      resource.ContactIds.size.should eq(0)
    end

    describe "listings" do

      it "should return the searches listings" do
        stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
        stub_api_get("/listings", 'listings/multiple.json', 
          {:_filter => "SavedSearch Eq '#{id}'"})
        listings = subject.class.find(id).listings
        listings.should be_an(Array)
        listings[0].should be_a(Listing)
      end
      
      it "should include the permissive parameter for provided searches" do
        stub_api_get("/provided/savedsearches/#{id}", 'saved_searches/get_provided.json')
        resource = subject.class.provided.find(id)
        expect(SparkApi.client).to receive(:get).with("/listings", 
          {:_filter => "SavedSearch Eq '#{id}'", :RequestMode => 'permissive'})
        resource.listings
      end
      
      it "should not include the permissive parameter for saved searches" do
        stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
        resource = subject.class.find(id)
        expect(SparkApi.client).to receive(:get).with("/listings", {:_filter => "SavedSearch Eq '#{id}'"})
        resource.listings
      end

    end

  end

  context "/provided/savedsearches", :support do
    on_get_it "should get provided SavedSearches" do
      stub_api_get("/provided/#{subject.class.element_name}", 'saved_searches/get.json')
      resources = subject.class.provided.get
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq(id)
    end
  end

  context "/savedsearches/tags/:tag", :support do
    on_get_it "should get tagged SavedSearches" do
      stub_api_get("/#{subject.class.element_name}/tags/Favorite", 'saved_searches/get.json')
      resources = subject.class.tagged("Favorite")
      resources.should be_an(Array)
    end
  end

  context "/savedsearches/<id>/contacts" do

    on_get_it "should return a list of contacts" do
      stub_api_get("/savedsearches/#{id}", "saved_searches/get.json")
      stub_api_get("/savedsearches/20101230223226074204000000", "saved_searches/get.json")

      resource = subject.class.find(id)
      contacts = resource.contacts
      contacts.should be_an(Array)
    end

    it "should return an empty array if model isn't persisted" do
      resource = SavedSearch.new
      resource.contacts.should be_an(Array)
    end
  end

  describe "favorite?" do
    it "should return true if the search has been tagged as a favorite" do
      search = SavedSearch.new(Tags: ["Favorites"])
      search.should be_favorite
    end

    it "should return false if the search has not been tagged as a favorite" do
      search = SavedSearch.new
      search.should_not be_favorite
    end
  end

  describe "can_have_newsfeed?" do

    before do
      stub_api_get("/newsfeeds/meta", "newsfeeds/meta.json")
    end

    it "should return false without at least three filter parameters" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      resource = subject.class.find(id)
      resource.stub(:has_active_newsfeed?) { false }
      resource.stub(:has_inactive_newsfeed?) { false }
      resource.Filter = "MlsStatus Eq 'Active' And PropertyType Eq 'A'"
      resource.can_have_newsfeed?.should == false
    end

    it "should return true with three filter parameters" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      resource = subject.class.find(id)
      resource.stub(:has_active_newsfeed?) { false }
      resource.stub(:has_inactive_newsfeed?) { false }
      resource.Filter = "MlsStatus Eq 'Active' And PropertyType Eq 'A' And ListPrice Eq 1000000"
      resource.can_have_newsfeed?.should == true
    end

  end

  describe "has_active_newsfeed?" do
    it "should return true if the search already has a newsfeed" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/with_newsfeed.json',
        { "_expand" => "NewsFeedSubscriptionSummary" } )
      resource = subject.class.find(id)
      resource.has_active_newsfeed?.should == true
    end

    it "should return false if the search doesn't have a newsfeed" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/without_newsfeed.json',
        { "_expand" => "NewsFeedSubscriptionSummary" } )
      resource = subject.class.find(id)
      resource.has_active_newsfeed?.should == false
    end
  end

  describe "has_inactive_newsfeed?" do
    it "should return true if the search has an inactive newsfeed" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/with_inactive_newsfeed.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/with_inactive_newsfeed.json',
        { "_expand" => "NewsFeedSubscriptionSummary" } )
      resource = subject.class.find(id)
      resource.has_inactive_newsfeed?.should == true
    end

    it "should return false if the search doesn't have a newsfeed" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/without_newsfeed.json',
        { "_expand" => "NewsFeedSubscriptionSummary, NewsFeeds" } )
      resource = subject.class.find(id)
      resource.has_inactive_newsfeed?.should == false
    end

  end

  describe "newsfeed" do
    it "should return the newsfeed for the saved search" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/with_newsfeed.json',
        { "_expand" => "NewsFeeds" } )      
      resource = subject.class.find(id)
      resource.newsfeeds.should be_an(Array)
    end
  end
  
end
