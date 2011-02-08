require './spec/spec_helper'

describe FlexmlsApi::Authentication do
  it "should give me a session object" do
    stub_auth_request
    stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/session/c401736bf3d3f754f07c04e460e09573").
      with(:query => {
        :ApiSig => "5596eff4550d74ec6802ac2d637ae5ae",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573"
      }).
      to_return(:body => fixture("session.json"))
    client = FlexmlsApi.client
    stub_auth_request
    session = client.get "/session/c401736bf3d3f754f07c04e460e09573"
    session[0]["AuthToken"].should eq "c401736bf3d3f754f07c04e460e09573"
  end
  it "should delete a session" do
    stub_auth_request
    stub_request(:delete, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/session/c401736bf3d3f754f07c04e460e09573").
      with(:query => {
        :ApiSig => "5596eff4550d74ec6802ac2d637ae5ae",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573"
      }).
      to_return(:body => fixture("success.json"))
    client = FlexmlsApi.client
    client.logout
    client.session.should eq nil
  end

end
