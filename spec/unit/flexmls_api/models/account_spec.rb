require './spec/spec_helper'

describe Account do
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
          "Name"=>"My Photo",
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
      (@account.send k.to_sym).should be_a(String)
    end
  end

  it "should have primary subresources" do
    @account.emails.primary.Address.should eq("work@test.com")
    @account.phones.primary.Number.should eq("701-555-1212")
    @account.addresses.primary.Address.should eq("101 Main Ave, Phoenix, AZ 12345")
    @account.websites.primary.Uri.should eq("http://iamthebestagent.com")
    @account.images.primary.should be(nil)
  end

  after(:each) do
    @acount = nil
  end

end
