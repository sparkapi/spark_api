require './spec/spec_helper'


describe Contact do
  before(:each) do
    stub_auth_request
  end
  
  it "should include the finders module" do
    Contact.should respond_to(:find)
    Contact.should respond_to(:my)
  end

  it "should get all my contacts" do
    stub_api_get("/contacts", 'contacts.json')
    contacts = Contact.get
    contacts.should be_an(Array)
    contacts.length.should eq(3)
    contacts.first.Id.should eq("20101230223226074201000000")
  end

  it "should get a single contact when using #my" do
    stub_api_get("/my/contact", 'contact_my.json')
    contact = Contact.my
    contact.should be_a(Contact)
    contact.Id.should == '20090928182824338901000000'
    contact.DisplayName.should == 'BH FOO'
  end

  it "should get all my Tags" do
    stub_api_get("/contacts/tags", 'contact_tags.json')
    tags = Contact.tags
    tags.should be_an(Array)
    tags.length.should eq(4)
    tags.first["Tag"].should eq("Current Buyers")
  end
  
  it "should get all my Tags" do
    stub_api_get("/contacts/tags/IDX%20Lead", 'contacts.json')
    contacts = Contact.by_tag("IDX Lead")
    contacts.should be_an(Array)
    contacts.length.should eq(3)
    contacts.first.Id.should eq("20101230223226074201000000")
    contacts.first.Tags[0].should eq("IDX Lead")
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
    stub_api_post("/contacts", 'contact_new_empty.json') do |request|
      request.to_return(:status => 400, :body => fixture('errors/failure.json'))
    end

    c=Contact.new
    c.save.should be(false)
    expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end
  
  context "on an epic fail" do
    it "should fail saving and asplode" do
      stub_api_post("/contacts", 'contact_new_empty.json') do |request|
        request.to_return(:status => 500, :body => fixture('errors/failure.json'))
      end
      
      c=Contact.new()
      expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
      expect{ c.save }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
    end
  end

end
