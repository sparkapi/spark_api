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
      stub_api_put("/portal", "portal/enable.json", "portal/post.json")
      portal = Portal.my
      portal.enable
    end

    it "should disable the current user's portal" do
      stub_api_get("/portal", "portal/my.json")
      stub_api_put("/portal", "portal/disable.json", "portal/post.json")
      portal = Portal.my
      portal.enable
    end

  end
end
