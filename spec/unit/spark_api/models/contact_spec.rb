require './spec/spec_helper'

describe Contact do
  before(:each) do
    stub_auth_request
  end

  it "should include the finders module" do
    expect(Contact).to respond_to(:find)
    expect(Contact).to respond_to(:my)
  end

  context "/contacts", :support do

    on_get_it "should get all my contacts" do
      stub_api_get("/contacts", 'contacts/contacts.json')
      contacts = Contact.get
      expect(contacts).to be_an(Array)
      expect(contacts.length).to eq(3)
      expect(contacts.first.Id).to eq("20101230223226074201000000")
    end

    on_post_it "should save a new contact" do
      stub_api_post("/contacts", 'contacts/new.json', 'contacts/post.json')
      c=Contact.new
      c.DisplayName = "Contact Four"
      c.PrimaryEmail = "contact4@fbsdata.com"
      expect(c.save).to be(true)
      expect(c.Id).to eq('20101230223226074204000000')
    end

    on_post_it "should save a new contact and notify" do
      stub_api_post("/contacts", 'contacts/new_notify.json', 'contacts/post.json')
      c = Contact.new
      c.notify = true
      c.attributes["DisplayName"] = "Contact Four"
      c.attributes["PrimaryEmail"] = "contact4@fbsdata.com"
      expect(c.save).to be(true)
      expect(c.Id).to eq('20101230223226074204000000')
      expect(c.ResourceUri).to eq('/v1/contacts/20101230223226074204000000')
    end

    on_post_it "should fail saving" do
      stub_api_post("/contacts", 'contacts/new_empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end

      c=Contact.new
      expect(c.save).to be(false)
      expect{ c.save! }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(400) }
    end

    on_post_it "should fail saving and set @errors" do
      stub_api_post("/contacts", 'contacts/new_empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure_with_msg.json'))
      end

      c=Contact.new
      expect(c.errors.length).to eq(0)
      expect(c.save).to be false
      expect(c.errors.length).to eq(1)
      expect(c.errors.first[:code]).to eq(1055)
    end

    context "on an epic fail" do
      on_post_it "should fail saving and asplode" do
        stub_api_post("/contacts", 'contacts/new_empty.json') do |request|
          request.to_return(:status => 500, :body => fixture('errors/failure.json'))
        end

        c=Contact.new()
        expect{ c.save! }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(500) }
        expect{ c.save }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(500) }
      end
    end

    context "/tags", :support do
      on_get_it "should get all my Tags" do
        stub_api_get("/contacts/tags", 'contacts/tags.json')
        tags = Contact.tags
        expect(tags).to be_an(Array)
        expect(tags.length).to eq(4)
        expect(tags.first["Tag"]).to eq("Current Buyers")
      end
    end

    context "/tags/<tag_name>", :support do
      on_get_it "should get all contacts with Tag <tag_name>" do
        stub_api_get("/contacts/tags/IDX%20Lead", 'contacts/contacts.json')
        contacts = Contact.by_tag("IDX Lead")
        expect(contacts).to be_an(Array)
        expect(contacts.length).to eq(3)
        expect(contacts.first.Id).to eq("20101230223226074201000000")
        expect(contacts.first.Tags[0]).to eq("IDX Lead")
      end
    end

    context "/export", :support do
      on_get_it "should get all contacts belonging to the current user" do
        stub_api_get("/contacts/export", 'contacts/contacts.json')
        expect(Contact).to respond_to(:export)
        contacts = Contact.export
        expect(contacts).to be_an(Array)
        expect(contacts.length).to eq(3)
      end
    end

    context "/export/all", :support do
      on_get_it "should get all contacts belonging to the current user" do
        stub_api_get("/contacts/export/all", 'contacts/contacts.json')
        expect(Contact).to respond_to(:export_all)
        contacts = Contact.export_all
        expect(contacts).to be_an(Array)
        expect(contacts.length).to eq(3)
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
        expect(saved_searches).to be_an(Array)
        expect(saved_searches.length).to eq(2)
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
        expect(saved_searches).to be_an(Array)
        expect(saved_searches.length).to eq(2)
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
        expect(listing_carts).to be_an(Array)
        expect(listing_carts.length).to eq(2)
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
        expect(vow_account.persisted?).to be true
      end
    end

    context "/comments", :support do

      it "should get all of a contact's comments" do
        s = stub_api_get("/contacts/#{contact_id}/comments", "comments/get.json")
        comments = Contact.new(:Id => contact_id).comments
        expect(comments.size).to eq(2)
        expect(s).to have_been_requested
      end

      it "should create a new contact comment" do
        s = stub_api_post("/contacts/#{contact_id}/comments", "comments/new.json", "comments/post.json")
        comment = Comment.new(:Comment => "This is a comment.")
        comment.parent = Contact.new(:Id => contact_id)
        expect(comment.save).to be(true)
        expect(comment.Id).to eq("20121114100201798092000005")
        expect(s).to have_been_requested
      end

      it "should create a new contact comment using helper method" do
        stub_api_get("/my/contact", 'contacts/my.json')
        s = stub_api_post("/contacts/#{contact_id}/comments", "comments/new.json", "comments/post.json")
        contact = Contact.my
        comment = contact.comment "This is a comment."
        expect(comment).to be_a(Comment)
        expect(s).to have_been_requested
      end

    end

    context "/comments/<id>", :support do

      let(:id) { "20121128133936712557000097" }

      on_delete_it "should remove a comment" do
        stub_api_get("/contacts/#{contact_id}/comments", "comments/get.json")
        s = stub_api_delete("/activities/20121128132106172132000004/comments/#{id}", "success.json")
        comment = Contact.new(:Id => contact_id).comments.first
        expect(comment.destroy).to eq(true)
        expect(s).to have_been_requested
      end

    end

  end

  context "/my/contact", :support do
    on_get_it "should get a single contact when using #my" do
      stub_api_get("/my/contact", 'contacts/my.json')
      contact = Contact.my
      expect(contact).to be_a(Contact)
      expect(contact.Id).to eq('20090928182824338901000000')
      expect(contact.DisplayName).to eq('BH FOO')
    end
  end

end
