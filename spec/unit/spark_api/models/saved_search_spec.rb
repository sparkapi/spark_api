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

  describe "can_have_newsfeed?" do

    it "should return false without at least three filter parameters" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      resource = subject.class.find(id)
      resource.Filter = "City Eq 'Moorhead' And MlsStatus Eq 'Active'"
      resource.can_have_newsfeed?.should == false

    end

    it "should return true with three filter parameters" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      resource = subject.class.find(id)
      resource.Filter = "City Eq 'Moorhead' And MlsStatus Eq 'Active' And PropertyType Eq 'A'"
      resource.can_have_newsfeed?.should == true
    end

  end

  describe "has_newsfeed?" do

    it "should return true if the search already has a newsfeed" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/with_newsfeed.json',
        { "_expand" => "NewsFeedSubscriptionSummary" } )
      resource = subject.class.find(id)
      resource.has_newsfeed?.should == true

    end

    it "should return false if the search doesn't already has a newsfeed" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/get.json')
      stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_searches/without_newsfeed.json',
        { "_expand" => "NewsFeedSubscriptionSummary" } )
      resource = subject.class.find(id)
      resource.has_newsfeed?.should == false
    end

  end

end
