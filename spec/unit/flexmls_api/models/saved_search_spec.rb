require './spec/spec_helper'

describe SavedSearch do

  before(:each) do
    stub_auth_request
  end

  let(:id){ "20100815220615294367000000" }

  context "/savedsearches", :support do
    on_get_it "should get all SavedSearches" do
      stub_api_get("/#{subject.class.element_name}", 'listings/saved_search.json')
      resources = subject.class.get
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq(id)
    end
  end

  context "/savedsearches/<search_id>", :support do
    on_get_it "should get a SavedSearch" do
      stub_api_get("/#{subject.class.element_name}/#{id}", 'listings/saved_search.json')
      resource = subject.class.find(id)
      resource.Id.should eq(id)
      resource.Name.should eq("Search name here")
    end
  end

  context "/provided/savedsearches", :support do
    on_get_it "should get provided SavedSearches" do
      stub_api_get("/provided/#{subject.class.element_name}", 'listings/saved_search.json')
      resources = subject.class.provided.get
      resources.should be_an(Array)
      resources.length.should eq(2)
      resources.first.Id.should eq(id)
    end
  end

end
