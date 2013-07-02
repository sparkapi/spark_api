require 'spec_helper'

describe IdxLink do

  before :each do
    stub_auth_request
  end

  it "gets a user's default link" do
    stub_api_get("/idxlinks/default", "idx_links/get.json")
    @idx_link = subject.class.default
    @idx_link.should be_an(IdxLink)
    @idx_link.Uri.should eq("http://link.dev.fbsdata.com/zq1fkiw4d3f,1")
  end

end
