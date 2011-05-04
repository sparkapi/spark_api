require './spec/spec_helper'

describe FlexmlsApi::Authentication::ApiAuth  do
  subject {FlexmlsApi::Authentication::ApiAuth.new(nil) }
  describe "build_param_hash" do
    it "should return a blank string when passed nil" do
      subject.build_param_string(nil).should be_empty
    end
    it "should return a correct param string for one item" do
      subject.build_param_string({:foo => "bar"}).should match("foobar")
    end
    it "should alphabatize the param names by key first, then by value" do
      subject.build_param_string({:zoo => "zar", :ooo => "car"}).should match("ooocarzoozar")
      subject.build_param_string({:Akey => "aValue", :aNotherkey => "AnotherValue"}).should 
           match "AkeyaValueaNotherkeyAnotherValue"
    end
  end
  
  describe "authenticate" do
    let(:client) { FlexmlsApi::Client.new({:api_key => "my_key", :api_secret => "my_secret"}) }
    subject do
      s = FlexmlsApi::Authentication::ApiAuth.new(client)
      client.authenticator = s
      s
    end
    it "should authenticate the api credentials" do
      stub_request(:post, "https://api.flexmls.com/#{FlexmlsApi.version}/session").
                  with(:query => {:ApiKey => "my_key", :ApiSig => "c731cf2455fbc7a4ef937b2301108d7a"}).
                  to_return(:body => fixture("session.json"))
      subject.authenticate()
    end
    it "should raise an error when api credentials are invalid" do
      stub_request(:post, "https://api.flexmls.com/#{FlexmlsApi.version}/session").
                  with(:query => {:ApiKey => "my_key", :ApiSig => "c731cf2455fbc7a4ef937b2301108d7a"}).
                  to_return(:body => fixture("authentication_failure.json"), :status=>401)
      expect {subject.authenticate()}.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 401 }
    end
  end

  describe "authenticated?" do
    let(:session) { Object.new }
    it "should return true when session is active" do
      subject.session = session
      session.stub(:expired?) { false }
      subject.authenticated?.should eq(true)
    end
    it "should return false when session is expired" do
      subject.session = session
      session.stub(:expired?) { true }
      subject.authenticated?.should eq(false)
    end
    it "should return false when session is uninitialized" do
      subject.authenticated?.should eq(false)
    end
  end

  describe "logout" do
    let(:session) { mock_session }
    let(:client) { Object.new }
    subject {FlexmlsApi::Authentication::ApiAuth.new(client) }
    it "should logout when there is an active session" do
      logged_out = false
      subject.session = session
      client.stub(:delete).with("/session/1234") { logged_out = true }
      subject.logout
      subject.session.should eq(nil)
      logged_out.should eq(true)
    end
    it "should skip logging out when there is no active session information" do 
      client.stub(:delete) { raise "Should not be called" }
      subject.logout.should eq(nil)
    end
  end
  
  # Since the request method is overly complex, the following tests just go through the whole stack
  # with some semi realistic requests.  Performing this type of test here should allow us to safely
  # mock out authentication for the rest of our unit tests and still have some decent coverage.
  describe "request" do
    let(:client) { FlexmlsApi::Client.new({:api_key => "my_key", :api_secret => "my_secret"}) }
    let(:session) { mock_session }
    subject do
      s = FlexmlsApi::Authentication::ApiAuth.new(client)
      client.authenticator = s
      s.session = session
      s
    end
    it "should handle a get request" do
      stub_auth_request
      args = {
        :ApiUser => "foobar",
        :_limit => '10',
        :_page => '1',
        :_pagination => '1'
      }
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings").
        with(:query => {
          :ApiSig => "1cb789831f8f4c6925dc708c93762a2c",
          :AuthToken => "1234"}.merge(args)).
        to_return(:body => fixture("listing_no_subresources.json"))
      subject.session = session
      subject.request(:get, "/#{FlexmlsApi.version}/listings", nil, args).status.should eq(200)
    end
    it "should handle a post request" do
      stub_auth_request
      args = {:ApiUser => "foobar"}
      contact = '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}'
      stub_request(:post, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/contacts").
        with(:query => {
          :ApiSig => "82898ef88d22e1b31bd2e2ea6bb8efe7",
          :AuthToken => "1234"}.merge(args),
          :body => contact
          ).
        to_return(:body => '{"D": {
          "Success": true, 
          "Results": [
            {
              "ResourceUri":"/v1/contacts/20101230223226074204000000"
            }]}
          }', 
          :status=>201)
      subject.request(:post, "/#{FlexmlsApi.version}/contacts", contact, args).status.should eq(201)
    end
  end
  
  describe "sign" do
    it "should sign the auth parameters correctly" do
      sign_token = "my_secretApiKeymy_key"
      subject.sign(sign_token).should eq("c731cf2455fbc7a4ef937b2301108d7a")
    end
  end
  
  context "when the server says the session is expired (even if we disagree)" do
    it "should reset the session and reauthenticate" do
      count = 0
      # Make sure the auth request goes out twice.
      stub_request(:post, "https://api.flexmls.com/#{FlexmlsApi.version}/session").
                  with(:query => {:ApiKey => "", :ApiSig => "806737984ab19be2fd08ba36030549ac"}).
                  to_return do |r|
                    count += 1
                    {:body => fixture("session.json")}
                  end
      # Fail the first time, but then return the correct value after reauthentication
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234").
          with(:query => {
            :ApiSig => "554b6e2a3efec8719b782647c19d238d",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573",
            :ApiUser => "foobar",
            :_expand => "Documents"
          }).
          to_return(:body => fixture('errors/expired.json'), :status => 401).times(1).then.
          to_return(:body => fixture('listing_with_documents.json'))
      l = Listing.find('1234', :_expand => "Documents")
      
      count.should eq(2)
      FlexmlsApi.client.session.expired?.should eq(false)
    end
  end
  
end
