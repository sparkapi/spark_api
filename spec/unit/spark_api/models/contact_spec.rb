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

    context "/tags", :support do
      on_get_it "should get all my Tags" do
        stub_api_get("/contacts/tags", 'contacts/tags.json')
        tags = Contact.tags
        tags.should be_an(Array)
        tags.length.should eq(4)
        tags.first["Tag"].should eq("Current Buyers")
      end
    end

    context "/tags/<tag_name>", :support do
      on_get_it "should get all contacts with Tag <tag_name>" do
        stub_api_get("/contacts/tags/IDX%20Lead", 'contacts/contacts.json')
        contacts = Contact.by_tag("IDX Lead")
        contacts.should be_an(Array)
        contacts.length.should eq(3)
        contacts.first.Id.should eq("20101230223226074201000000")
        contacts.first.Tags[0].should eq("IDX Lead")
      end
    end

    context "/export", :support do
      on_get_it "should get all contacts belonging to the current user" do
        stub_api_get("/contacts/export", 'contacts/contacts.json')
        Contact.should respond_to(:export)
        contacts = Contact.export
        contacts.should be_an(Array)
        contacts.length.should eq(3)
      end
    end

    context "/export/all", :support do
      on_get_it "should get all contacts belonging to the current user" do
        stub_api_get("/contacts/export/all", 'contacts/contacts.json')
        Contact.should respond_to(:export_all)
        contacts = Contact.export_all
        contacts.should be_an(Array)
        contacts.length.should eq(3)
      end
    end

  end

  context "/contacts/<contact_id>", :support do

    let(:contact_id) { "20090928182824338901000000" }

    context "/savedsearches" do

      subject(:contact) do
        stub_api_get("/my/contact", 'contacts/my.json')
        contact = Contact.my
      end

      on_get_it "should get all the saved searches belonging to the customer" do
        stub_api_get("/contacts/#{contact.Id}/savedsearches", 'saved_searches/get.json')
        saved_searches = contact.saved_searches
        saved_searches.should be_an(Array)
        saved_searches.length.should eq(2)
      end

      it "should pass any arguments as parameters" do
        stub_api_get("/contacts/#{contact.Id}/savedsearches", 'saved_searches/get.json', :_pagination => 1)
        saved_searches = contact.saved_searches(:_pagination => 1)
      end

    end

    context "/provided/savedsearches", :support do

      subject(:contact) do
        stub_api_get("/my/contact", 'contacts/my.json')
        contact = Contact.my
      end

      on_get_it "should get all the provided searches belonging to the customer" do
        stub_api_get("/contacts/#{contact.Id}/provided/savedsearches", 'saved_searches/get.json')
        saved_searches = contact.provided_searches
        saved_searches.should be_an(Array)
        saved_searches.length.should eq(2)
      end

      it "should pass any arguments as parameters" do
        stub_api_get("/contacts/#{contact.Id}/provided/savedsearches", 'saved_searches/get.json', :_pagination => 1)
        saved_searches = contact.provided_searches(:_pagination => 1)
      end

    end

    context "/listingcarts", :support do

      subject(:contact) do
        stub_api_get("/my/contact", 'contacts/my.json')
        Contact.my
      end

      on_get_it "should get all the listing carts belonging to the customer" do
        stub_api_get("/contacts/#{contact.Id}/listingcarts", 'listing_carts/listing_cart.json')
        listing_carts = contact.listing_carts
        listing_carts.should be_an(Array)
        listing_carts.length.should eq(2)
      end

      it "should pass any arguments as parameters" do
        stub_api_get("/contacts/#{contact.Id}/listingcarts", 'listing_carts/listing_cart.json', :test_argument => "yay")
        contact.listing_carts(:test_argument => "yay")
      end
    end

    context "/portal", :support do
      on_get_it "should return account information for the current user/contact?" do
        stub_api_get("/my/contact", 'contacts/my.json')
        contact = Contact.my
        stub_api_get("/contacts/#{contact.Id}/portal", 'contacts/vow_accounts/get.json')
        vow_account = contact.vow_account
        vow_account.persisted?.should be_true
      end
    end

    context "/comments", :support do

      it "should get all of a contact's comments" do
        s = stub_api_get("/contacts/#{contact_id}/comments", "comments/get.json")
        comments = Contact.new(:Id => contact_id).comments
        comments.size.should eq(2)
        s.should have_been_requested
      end

      it "should create a new contact comment" do
        s = stub_api_post("/contacts/#{contact_id}/comments", "comments/new.json", "comments/post.json")
        comment = Comment.new(:Comment => "This is a comment.")
        comment.parent = Contact.new(:Id => contact_id)
        comment.save.should be(true)
        comment.Id.should eq("20121114100201798092000005")
        s.should have_been_requested
      end

      it "should create a new contact comment using helper method" do
        stub_api_get("/my/contact", 'contacts/my.json')
        s = stub_api_post("/contacts/#{contact_id}/comments", "comments/new.json", "comments/post.json")
        contact = Contact.my
        comment = contact.comment "This is a comment."
        comment.should be_a(Comment)
        s.should have_been_requested
      end

    end

    context "/comments/<id>", :support do

      let(:id) { "20121128133936712557000097" }

      on_delete_it "should remove a comment" do
        stub_api_get("/contacts/#{contact_id}/comments", "comments/get.json")
        s = stub_api_delete("/activities/20121128132106172132000004/comments/#{id}", "success.json")
        comment = Contact.new(:Id => contact_id).comments.first
        comment.destroy.should eq(true)
        s.should have_been_requested
      end

    end

    context "/messages", :support do

      it "should get all of a contact's messages" do
        s = stub_api_get("/contacts/#{contact_id}/messages", "messages/get.json")
        messages = Contact.new(:Id => contact_id).messages
        messages.size.should eq(2)
        s.should have_been_requested
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

end
