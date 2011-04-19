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
      stub.get('/v1/contacts?ApiSig=33e3b6d6436c85c3f9944d21f6f0cf9a&ApiUser=foobar&AuthToken=1234') { [200, {}, fixture('contacts.json')] 
      }
      stub.post('/v1/contacts?ApiSig=1c78fb9f798fbb739a0b8152528cd453&ApiUser=foobar&AuthToken=1234', '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}') { [201, {}, '{"D": {
        "Success": true, 
        "Results": [
          {
            "ResourceUri":"/v1/contacts/20101230223226074204000000"
          }]}
        }'] 
      }
      stub.post('/v1/contacts?ApiSig=ea132fe27a8deb7d6c096b102972ce3e&ApiUser=foobar&AuthToken=1234', '{"D":{"Contacts":[{}]}}') { [400, {}, '{"D": {
        "Success": false}
        }'] 
      }
    end
    Contact.connection = mock_client(stubs)
  end
  
  it "should include the finders module" do
    Contact.should respond_to(:find)
  end

  it "should get all my contacts" do
    contacts = Contact.get
    contacts.should be_an(Array)
    contacts.length.should eq(3)
    contacts.first.Id.should eq("20101230223226074201000000")
  end

  it "should save a new contact" do
    c=Contact.new
    c.attributes["DisplayName"] = "Contact Four"
    c.attributes["PrimaryEmail"] = "contact4@fbsdata.com"
    c.save.should be(true)
    c.Id.should eq('20101230223226074204000000')
  end

  it "should fail saving" do
    c=Contact.new
    c.save.should be(false)
    expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end
  
  context "on an epic fail" do
    before(:all) do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/v1/contacts?ApiSig=ea132fe27a8deb7d6c096b102972ce3e&ApiUser=foobar&AuthToken=1234', '{"D":{"Contacts":[{}]}}') { [500, {}, '{"D": {
          "Success": false}
          }'] 
        }
      end
      Contact.connection = mock_client(stubs)
    end
    it "should fail saving and asplode" do
      c=Contact.new()
      expect{ c.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
      expect{ c.save }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 500 }
    end
  end

end
