require './spec/spec_helper'

describe SparkApi::Authentication do
  before(:all) do
    SparkApi.reset
  end
  
  after(:all) do
    reset_config
  end

  it "should give me a session object" do
    stub_auth_request
    stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/session/c401736bf3d3f754f07c04e460e09573").
      with(:query => {
        :ApiSig => "5596eff4550d74ec6802ac2d637ae5ae",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573"
      }).
      to_return(:body => fixture("session.json"))
    client = SparkApi.client
    stub_auth_request
    session = client.get "/session/c401736bf3d3f754f07c04e460e09573"
    session[0]["AuthToken"].should eq("c401736bf3d3f754f07c04e460e09573")
  end
  it "should delete a session" do
    stub_auth_request
    stub_request(:delete, "#{SparkApi.endpoint}/#{SparkApi.version}/session/c401736bf3d3f754f07c04e460e09573").
      with(:query => {
        :ApiSig => "5596eff4550d74ec6802ac2d637ae5ae",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573"
      }).
      to_return(:body => fixture("success.json"))
    client = SparkApi.client
    client.logout
    client.session.should eq(nil)
  end

end
