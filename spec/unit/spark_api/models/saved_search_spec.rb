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

end
