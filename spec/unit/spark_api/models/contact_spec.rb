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

  context "/contact/export", :support do
    on_get_it "should get all contacts belonging to the current user" do
      stub_api_get("/contacts/export", 'contacts/contacts.json')
      Contact.should respond_to(:export)
      contacts = Contact.export
      contacts.should be_an(Array)
      contacts.length.should eq(3)
    end

  end

  context "/contact/export/all", :support do
    on_get_it "should get all contacts belonging to the current user" do
      stub_api_get("/contacts/export/all", 'contacts/contacts.json')
      Contact.should respond_to(:export_all)
      contacts = Contact.export_all
      contacts.should be_an(Array)
      contacts.length.should eq(3)
    end

  end

  context "/contacts/<contact_id>/savedsearches", :support do
    on_get_it "should get all the saved searches belonging to the customer" do
      stub_api_get("/my/contact", 'contacts/my.json')
      contact = Contact.my
      stub_api_get("/contacts/#{contact.Id}/savedsearches", 'saved_searches/get.json')
      contact.should respond_to(:saved_searches)
      saved_searches = contact.saved_searches
      saved_searches.should be_an(Array)
      saved_searches.length.should eq(2)
    end

    on_post_it "should create the new saved searches" do
      stub_api_get("/my/contact", 'contacts/my.json')
      contact = Contact.my
      stub_api_get("/contacts/#{contact.Id}/savedsearches", 'contacts/saved_searches/get.json')
      contact.saved_searches_will_change!
      contact.saved_searches << SavedSearch.new({ :Name => "A new search name here", :Filter => "City eq 'Test 1'" })
      contact.saved_searches << SavedSearch.new({ :Name => "A new search name here", :Filter => "City eq 'Test 1'" })
      contact.saved_searches.length.should eq(4)
      stub_api_post("/contacts/#{contact.Id}/savedsearches", "contacts/saved_searches/new.json", "saved_searches/post.json")
      contact.save.should be true
    end

  end

  context "/contacts/<contact_id>/listingcarts", :support do
     on_get_it "should get all the listing carts belonging to the customer" do
       stub_api_get("/my/contact", 'contacts/my.json')
       contact = Contact.my
       stub_api_get("/contacts/#{contact.Id}/listingcarts", 'listing_carts/listing_cart.json')
       contact.should respond_to(:listing_carts)
       saved_searches = contact.listing_carts
       saved_searches.should be_an(Array)
       saved_searches.length.should eq(2)
     end

     on_post_it "should create the new listing carts" do
       stub_api_get("/my/contact", 'contacts/my.json')
       contact = Contact.my
       stub_api_get("/contacts/#{contact.Id}/listingcarts", 'contacts/listing_carts/get.json')
       contact.listing_carts_will_change!
       contact.listing_carts << ListingCart.new({:Name => "LC A", :ListingIds => ['20081118213437693901000000']})
       contact.listing_carts << ListingCart.new({:Name => "LC B", :ListingIds => ['20081118213437693901000000']})
       contact.listing_carts << ListingCart.new({:Name => "LC C", :ListingIds => ['20081118213437693901000000','20081118213437693901000000']})
       contact.listing_carts.length.should eq(5)
       stub_api_post("/contacts/#{contact.Id}/listingcarts", "contacts/listing_carts/new.json", "listing_carts/post.json")
       contact.save.should be true
     end

  end

  context  "/contacts/<contact_id>/portal", :support do
    on_get_it "should return account information for the current user/contact?" do
      stub_api_get("/my/contact", 'contacts/my.json')
      contact = Contact.my
      stub_api_get("/contacts/#{contact.Id}/portal", 'contacts/vow_accounts/get.json')
      vow_account = contact.vow_account
      vow_account.persisted?.should be_true
    end

    on_post_it "should create a consumer account" do

    end

    on_put_it "should update a consumer account" do

    end

  end



end
