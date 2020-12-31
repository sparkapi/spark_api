require 'spec_helper'

describe VowAccount do
  before :each do
    stub_auth_request
    stub_api_get("/my/contact", 'contacts/my.json')
    @contact = Contact.my
    stub_api_get("/contacts/#{@contact.Id}/portal", 'contacts/vow_accounts/get.json')
    @vow_account = @contact.vow_account
  end

  context "/contacts/<contact_id>/portal" do
    on_post_it "should create a consumer account" do
      s = stub_api_post("/contacts/20090928182824338901000000/portal", "contacts/vow_accounts/new.json", "contacts/vow_accounts/post.json")
      vow = VowAccount.new({
          "LoginName" => "Johnny Everyman",
          "Password" => "MyPassw0rd",
          "Settings" => {"Enabled" => "true"},
          "Locale" => {"Language" => "en"}
      })
      vow.parent = Contact.new(:Id => "20090928182824338901000000")
      vow.save
      expect(s).to have_been_requested
    end

    on_post_it "should create an empty consumer account" do
      s = stub_api_post("/contacts/20090928182824338901000000/portal", nil, "contacts/vow_accounts/post.json")
      vow = VowAccount.new
      vow.parent = Contact.new(:Id => "20090928182824338901000000")
      vow.save
      expect(s).to have_been_requested
    end

    on_put_it "should update a consumer account details" do
      @vow_account.LoginName
      @vow_account.LoginName = "Johnny Newman"
      s = stub_api_put("/contacts/20090928182824338901000000/portal", "contacts/vow_accounts/edit.json", "contacts/vow_accounts/post.json")
      @vow_account.save
      expect(s).to have_been_requested
    end

    it "should enable the current account" do
      s = stub_api_put("/contacts/20090928182824338901000000/portal", {"Settings" => {"Enabled" => "true"}}, "contacts/vow_accounts/post.json")
      @vow_account.enable
      expect(@vow_account.enabled?).to be true
      expect(s).to have_been_requested
    end

    it "should disable the current account" do
      s = stub_api_put("/contacts/20090928182824338901000000/portal", {"Settings" => {"Enabled" => "false"}}, "contacts/vow_accounts/post.json")
      @vow_account.disable
      expect(@vow_account.enabled?).to be false
      expect(s).to have_been_requested
    end

    it "should change the password" do
      s = stub_api_put("/contacts/20090928182824338901000000/portal", {"Password" => "NewPassw0rd123"}, "contacts/vow_accounts/post.json")
      @vow_account.change_password("NewPassw0rd123")
      expect(s).to have_been_requested
    end

  end

end
