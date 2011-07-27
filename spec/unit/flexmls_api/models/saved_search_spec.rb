require './spec/spec_helper'

describe SavedSearch do
  
  before(:each) do
    stub_auth_request
  end

  let(:id){ "20100815220615294367000000" }
    
  it "should get all SavedSearches" do
    stub_api_get("/#{subject.class.element_name}", 'saved_search.json')
    resources = subject.class.get
    resources.should be_an(Array)
    resources.length.should eq(2)
    resources.first.Id.should eq(id)
  end

  it "should get a SavedSearch" do
    stub_api_get("/#{subject.class.element_name}/#{id}", 'saved_search.json')
    resource = subject.class.find(id)
    resource.Id.should eq(id)
    resource.Name.should eq("Search name here")
  end

  it "should get provided SavedSearches" do
    stub_api_get("/provided/#{subject.class.element_name}", 'saved_search.json')
    resources = subject.class.provided.get
    resources.should be_an(Array)
    resources.length.should eq(2)
    resources.first.Id.should eq(id)
  end

end
