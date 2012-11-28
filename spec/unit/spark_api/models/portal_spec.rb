require 'spec_helper'

describe Portal do

  before :each do
    stub_auth_request
  end

  context "/portal" do

    it "should return a new portal if the current user doesn't have one yet" do
      stub_api_get("/portal", "portal/my_non_existant.json")
      portal = Portal.my
      portal.persisted?.should eq(false)
    end

    it "should get the current user's portal" do
      stub_api_get("/portal", "portal/my.json")
      portal = Portal.my
      portal.persisted?.should eq(true)
    end

    it "should create a portal for the current user" do
      stub_api_post("/portal", "portal/new.json", "portal/post.json")
      portal = Portal.new({
        :DisplayName => "GreatPortal",
        :Enabled => true,
        :RequiredFields => [ "Address", "Phone" ]
      })
      portal.save
    end

    it "should enable the current user's portal" do
      stub_api_get("/portal", "portal/my.json")
      s = stub_api_put("/portal/20100912153422758914000000", "portal/enable.json", "portal/post.json")
      portal = Portal.my
      portal.enable
      s.should have_been_requested
    end

    it "should disable the current user's portal" do
      stub_api_get("/portal", "portal/my.json")
      s = stub_api_put("/portal/20100912153422758914000000", "portal/disable.json", "portal/post.json")
      portal = Portal.my
      portal.disable
      s.should have_been_requested
    end

  end
end
