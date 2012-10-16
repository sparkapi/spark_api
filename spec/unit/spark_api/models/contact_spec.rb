require './spec/spec_helper'

describe Contact do
  before(:each) do
    stub_auth_request
  end

  it "should include the finders module" do
    Contact.should respond_to(:find)
    Contact.should respond_to(:my)
  end

  context "/contacts", :support do
    on_get_it "should get all my contacts" do
      stub_api_get("/contacts", 'contacts/contacts.json')
      contacts = Contact.get
      contacts.should be_an(Array)
      contacts.length.should eq(3)
      contacts.first.Id.should eq("20101230223226074201000000")
    end

    on_post_it "should save a new contact" do
      stub_api_post("/contacts", 'contacts/new.json', 'contacts/post.json')
      c=Contact.new
      c.DisplayName = "Contact Four"
      c.PrimaryEmail = "contact4@fbsdata.com"
      c.save.should be(true)
      c.Id.should eq('20101230223226074204000000')
    end

    on_post_it "should save a new contact and notify" do
      stub_api_post("/contacts", 'contacts/new_notify.json', 'contacts/post.json')
      c = Contact.new
      c.notify = true
      c.attributes["DisplayName"] = "Contact Four"
      c.attributes["PrimaryEmail"] = "contact4@fbsdata.com"
      c.save.should be(true)
      c.Id.should eq('20101230223226074204000000')
      c.ResourceUri.should eq('/v1/contacts/20101230223226074204000000')
    end

    on_post_it "should fail saving" do
      stub_api_post("/contacts", 'contacts/new_empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end

      c=Contact.new
      c.save.should be(false)
      expect{ c.save! }.to raise_error(SparkApi::ClientError){ |e| e.status.should == 400 }
    end

    on_post_it "should fail saving and set @errors" do
      stub_api_post("/contacts", 'contacts/new_empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure_with_msg.json'))
      end

      c=Contact.new
      c.errors.length.should eq(0)
      c.save.should be_false
      c.errors.length.should eq(1)
      c.errors.first[:code].should eq(1055)
    end

    context "on an epic fail" do
      on_post_it "should fail saving and asplode" do
        stub_api_post("/contacts", 'contacts/new_empty.json') do |request|
          request.to_return(:status => 500, :body => fixture('errors/failure.json'))
        end

        c=Contact.new()
        expect{ c.save! }.to raise_error(SparkApi::ClientError){ |e| e.status.should == 500 }
        expect{ c.save }.to raise_error(SparkApi::ClientError){ |e| e.status.should == 500 }
      end
    end
  end

  context "/my/contact", :support do
    on_get_it "should get a single contact when using #my" do
      stub_api_get("/my/contact", 'contacts/my.json')
      contact = Contact.my
      contact.should be_a(Contact)
      contact.Id.should == '20090928182824338901000000'
      contact.DisplayName.should == 'BH FOO'
    end
  end

  context "/contact/tags", :support do
    on_get_it "should get all my Tags" do
      stub_api_get("/contacts/tags", 'contacts/tags.json')
      tags = Contact.tags
      tags.should be_an(Array)
      tags.length.should eq(4)
      tags.first["Tag"].should eq("Current Buyers")
    end
  end

  context "/contact/tags/<tag_name>", :support do
    on_get_it "should get all contacts with Tag <tag_name>" do
      stub_api_get("/contacts/tags/IDX%20Lead", 'contacts/contacts.json')
      contacts = Contact.by_tag("IDX Lead")
      contacts.should be_an(Array)
      contacts.length.should eq(3)
      contacts.first.Id.should eq("20101230223226074201000000")
      contacts.first.Tags[0].should eq("IDX Lead")
    end
  end

end
