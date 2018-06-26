require './spec/spec_helper'

describe Account do
  describe "units" do
    before(:each) do
      @account = Account.new({
        "Name"=>"Sample User",
        "Id"=>"20000426173054342350000000",
        "Office"=>"Sample Office",
        "Mls"=>"Sample MLS",
        "MlsId"=>"20000426143505724628000000",
        "Emails"=>[
          {
            "Type"=>"Work",
            "Name"=>"My Work E-mail",
            "Address"=>"work@test.com",
            "Primary"=>true
          },
          {
            "Type"=>"Home",
            "Name"=>"My Home E-mail",
            "Address"=>"home@test.com"
          }
        ],
        "Phones"=>[
          {
            "Type"=>"Work",
            "Name"=>"My Work Phone",
            "Number"=>"701-555-1212",
            "Primary"=>true
          },
          {
            "Type"=>"Home",
            "Name"=>"My Home Phone",
            "Number"=>"702-555-1313"
          }
        ],
        "Websites"=>[
          {
            "Type"=>"Work",
            "Name"=>"My Work Website",
            "Uri"=>"http://iamthebestagent.com",
            "Primary"=>true
          },
          {
            "Type"=>"Home",
            "Name"=>"My Home Website",
            "Uri"=>"http://myspace.com/lolcats"
          }
        ],
        "Addresses"=>[
          {
            "Type"=>"Work",
            "Name"=>"My Work Address",
            "Address"=>"101 Main Ave, Phoenix, AZ 12345",
            "Primary"=>true
          },
          {
            "Type"=>"Home",
            "Name"=>"My Home Address",
            "Address"=>"102 Main Ave, Gilbert, AZ 54321"
          }
        ],
        "Images"=>[
          {
            "Type"=>"Photo",
            "Name"=>"My Photo 1",
            "Uri"=>"http://photos.flexmls.com/az/...."
          },
          {
            "Type"=>"Photo",
            "Name"=>"My Photo two",
            "Uri"=>"http://photos.flexmls.com/az/...."
          },
          {
            "Type"=>"Photo",
            "Name"=>nil,
            "Uri"=>"http://photos.flexmls.com/az/...."
          },
          {
            "Type"=>"Logo",
            "Name"=>"1 My Logo",
            "Uri"=>"http://photos.flexmls.com/az/...."
          },
          {
            "Type"=>"Logo",
            "Name"=>"My Other Logo",
            "Uri"=>"http://photos.flexmls.com/az/...."
          },
          {
            "Type"=>"Logo",
            "Name"=>"My Logo",
            "Uri"=>"http://photos.flexmls.com/az/...."
          }
        ]
      })
    end

    it "should respond to attributes" do
      ['Name','Id','Mls','MlsId','Office'].each do |k|
        expect(@account.send k.to_sym).to be_a(String)
      end
    end

    it "should have primary subresources" do
      expect(@account.emails.primary.Address).to eq("work@test.com")
      expect(@account.phones.primary.Number).to eq("701-555-1212")
      expect(@account.addresses.primary.Address).to eq("101 Main Ave, Phoenix, AZ 12345")
      expect(@account.websites.primary.Uri).to eq("http://iamthebestagent.com")
    end

    it "should be able to provide a primary image" do
      expect(@account.primary_img("Photo").Name).to eq('My Photo 1')
      expect(@account.primary_img("Logo").Name).to eq('1 My Logo')
    end

    after(:each) do
      @acount = nil
    end
  end

  describe "functionals" do
    before(:each) do
      stub_auth_request
    end

    context "/my/account", :support do
      on_get_it "should get my account" do
        stub_api_get("/my/account", 'accounts/my.json')
        account = Account.my
        expect(account.Id).to eq("20000426173054342350000000")
        expect(account.websites.first.Name).to eq('My Work Website')
      end

      on_put_it "should save my portal account" do
        stub_api_get("/my/account", 'accounts/my_portal.json')
        stub_api_put("/my/account", 'accounts/my_save.json', 'accounts/my_put.json')
        account = Account.my
        expect(account.Id).to eq("20110426173054342350000000")
        expect(account.GetEmailUpdates).to eq(false)
        account.GetEmailUpdates = true
        account.save!
        expect(account.GetEmailUpdates).to eq(true)
      end
    end

    context "/accounts" do
      on_get_it "should get all accounts" do
        stub_api_get("/accounts", 'accounts/all.json')
        accounts = Account.get
        expect(accounts).to be_an(Array)
        expect(accounts.length).to eq(3)
        expect(accounts.first.Id).to eq("20000426173054342350000000")
        expect(accounts.last.Id).to eq("20110126173054382350000000")
      end
      on_put_it "should save password" do
        stub_api_get("/my/account", 'accounts/my.json')
        account = Account.my
        stub_api_put("/accounts/#{account.Id}", 'accounts/password_save.json', 'accounts/my.json')
        account.Password = "1"
        account.PasswordValidation = "1"
        expect(account.save).to be(true)
      end   
    end

    context "/accounts/by/office/<office_id>" do
      on_get_it "should all office accounts" do
        stub_api_get("/accounts/by/office/20030426173014239760000000", 'accounts/office.json')
        accounts = Account.by_office("20030426173014239760000000")
        expect(accounts).to be_an(Array)
        expect(accounts.length).to eq(2)
        accounts.each do |account|
          expect(accounts.first.OfficeId).to eq("20030426173014239760000000")
        end
      end
    end

  end

end

