require 'spec_helper'

describe IdxLink do

  before :each do
    stub_auth_request
  end

  describe "/idxlinks/default" do

    on_get_it "returns an agent's default idx link" do
      s = stub_api_get("/idxlinks/default", "idx_links/get.json")
      @idx_link = subject.class.default
      @idx_link.should be_an(IdxLink)
      @idx_link.Uri.should eq("http://link.dev.fbsdata.com/zq1fkiw4d3f,1")
      s.should have_been_requested
    end

    on_get_it "returns nil if the user doesn't have one" do
      s = stub_api_get("/idxlinks/default", "no_results.json")
      @idx_link = subject.class.default
      @idx_link.should be_nil
      s.should have_been_requested
    end

  end

end
