require 'spec_helper'

describe QuickSearch do

  before :each do
    stub_auth_request
  end

  context '/searchtemplates/quicksearches' do
    it "gets a current user's quick searches" do
      s = stub_api_get("/searchtemplates/quicksearches", "search_templates/quick_searches/get.json")
      quicksearches = QuickSearch.get
      quicksearches.should be_an(Array)
      quicksearches.size.should eq(2)
      s.should have_been_requested
    end
  end

  context '/searchtemplates/quicksearches/<id>' do

    let(:id) { "20121128132106172132000004" }

    it "gets an individual quick search" do
      s = stub_api_get("/searchtemplates/quicksearches/#{id}", "search_templates/quick_searches/get.json") 
      quicksearch = QuickSearch.find(id) 
      quicksearch.should be_an(QuickSearch)
      s.should have_been_requested
    end

    it "should have fields" do
      stub_api_get("/searchtemplates/quicksearches/#{id}", "search_templates/quick_searches/get.json") 
      quicksearch = QuickSearch.find(id) 
      s = stub_api_get("/searchtemplates/quicksearches/#{quicksearch.Id}", "search_templates/quick_searches/get.json",
        {:_expand => "Fields"}) 
      quicksearch.fields.size.should eq(2)
      s.should have_been_requested
    end

  end

end
