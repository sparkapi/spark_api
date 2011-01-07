require './spec/spec_helper'


class Contact
  class << self
    # Neato trick, using the accessor function nested here acts on the class methods!
    attr_accessor :connection
  end
end

describe Contact do
  before(:all) do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/v1/contacts?ApiSig=735774295be070a27f7cf859fde90740&AuthToken=1234') { [200, {}, '{"D": {
        "Success": true, 
        "Results": [
          {
            "ResourceUri":"/v1/contacts/20101230223226074201000000",
            "DisplayName":"Contact One",
            "Id":"20101230223226074201000000",
            "PrimaryEmail":"contact1@fbsdata.com"
          },
          {
            "ResourceUri":"/v1/contacts/20101230223226074202000000",
            "DisplayName":"Contact Two",
            "Id":"20101230223226074202000000",
            "PrimaryEmail":"contact2fbsdata.com"
          },
          {
            "ResourceUri":"/v1/contacts/20101230223226074203000000",
            "DisplayName":"Contact Three",
            "Id":"20101230223226074203000000",
            "PrimaryEmail":"contact3@fbsdata.com"
          }]}
        }'] 
      }
      stub.post('/v1/contacts?ApiSig=7f0a7b0f648f87aabd4d4393913a10ba&AuthToken=1234', '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}') { [201, {}, '{"D": {
        "Success": true, 
        "Results": [
          {
            "ResourceUri":"/v1/contacts/20101230223226074204000000"
          }]}
        }'] 
      }
      stub.post('/v1/contacts?ApiSig=76f6ee7032f7038d737f9b73457f06e2&AuthToken=1234', '{"D":{"Contacts":[{}]}}') { [500, {}, '{"D": {
        "Success": false}
        }'] 
      }
    end
    Contact.connection = mock_client(stubs)
  end
  
  it "should get all my contacts" do
    contacts = Contact.get
    contacts.should be_an Array
    contacts.length.should eq 3
    contacts.first.Id.should eq "20101230223226074201000000"
  end

  it "should save a new contact" do
    c=Contact.new
    c.attributes["DisplayName"] = "Contact Four"
    c.attributes["PrimaryEmail"] = "contact4@fbsdata.com"
    c.save.should be true
    c.Id.should eq '20101230223226074204000000'
  end

  it "should fail saving" do
    c=Contact.new
    c.save.should be false
  end

  it "should fail saving and asplode" do
    c=Contact.new()
    expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
  end

end
