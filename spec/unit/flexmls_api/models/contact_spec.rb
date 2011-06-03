require './spec/spec_helper'


describe Contact do
  before(:each) do
    stub_auth_request
  end
  
  it "should include the finders module" do
    Contact.should respond_to(:find)
  end

  it "should get all my contacts" do
    stub_api_get("/contacts", 'contacts.json')
    contacts = Contact.get
    contacts.should be_an(Array)
    contacts.length.should eq(3)
    contacts.first.Id.should eq("20101230223226074201000000")
  end

  it "should save a new contact" do
    stub_api_post("/contacts", 'contact_new.json', 'contacts_post.json')
    c=Contact.new
    c.attributes["DisplayName"] = "Contact Four"
    c.attributes["PrimaryEmail"] = "contact4@fbsdata.com"
    c.save.should be(true)
    c.Id.should eq('20101230223226074204000000')
  end

  it "should save a new contact and notify" do
    stub_api_post("/contacts", 'contact_new_notify.json', 'contacts_post.json')
    c=Contact.new
    c.notify=true
    c.attributes["DisplayName"] = "Contact Four"
    c.attributes["PrimaryEmail"] = "contact4@fbsdata.com"
    c.save.should be(true)
    c.Id.should eq('20101230223226074204000000')
  end

  it "should fail saving" do
    stub_request(:post, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/contacts").
      with(:query => {
        :ApiSig => "afb8bd30fe41de3e1e738a6dec7de41d",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573",
        :ApiUser => "foobar",
      },
      :body => JSON.parse(fixture('contact_new_empty.json').read).to_json
      ).
      to_return(:status => 400, :body => fixture('errors/failure.json'))
    c=Contact.new
    c.save.should be(false)
    expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end
  
  context "on an epic fail" do
    it "should fail saving and asplode" do
      stub_request(:post, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/contacts").
        with(:query => {
          :ApiSig => "afb8bd30fe41de3e1e738a6dec7de41d",
          :AuthToken => "c401736bf3d3f754f07c04e460e09573",
          :ApiUser => "foobar",
        },
        :body => JSON.parse(fixture('contact_new_empty.json').read).to_json
        ).
        to_return(:status => 500, :body => fixture('errors/failure.json'))
      c=Contact.new()
      expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
      expect{ c.save }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
    end
  end

end
