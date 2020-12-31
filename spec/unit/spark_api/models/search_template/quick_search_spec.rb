require 'spec_helper'

describe QuickSearch do

  before :each do
    stub_auth_request
  end

  context '/searchtemplates/quicksearches' do
    it "gets a current user's quick searches" do
      s = stub_api_get("/searchtemplates/quicksearches", "search_templates/quick_searches/get.json")
      quicksearches = QuickSearch.get
      expect(quicksearches).to be_an(Array)
      expect(quicksearches.size).to eq(2)
      expect(s).to have_been_requested
    end
  end

  context '/searchtemplates/quicksearches/<id>' do
    let(:id) { "20121128132106172132000004" }
    it "gets an individual quick search" do
      s = stub_api_get("/searchtemplates/quicksearches/#{id}", "search_templates/quick_searches/get.json")
      quicksearch = QuickSearch.find(id)
      expect(quicksearch).to be_an(QuickSearch)
      expect(s).to have_been_requested
    end
  end

end
