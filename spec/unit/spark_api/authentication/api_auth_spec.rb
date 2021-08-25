require './spec/spec_helper'

describe SparkApi::Authentication::ApiAuth  do
  subject {SparkApi::Authentication::ApiAuth.new(nil) }
  describe "build_param_hash" do
    it "should return a blank string when passed nil" do
      expect(subject.build_param_string(nil)).to be_empty
    end
    it "should return a correct param string for one item" do
      expect(subject.build_param_string({:foo => "bar"})).to match("foobar")
    end
    it "should alphabatize the param names by key first, then by value" do
      expect(subject.build_param_string({:zoo => "zar", :ooo => "car"})).to match("ooocarzoozar")
      expect(subject.build_param_string({:Akey => "aValue", :aNotherkey => "AnotherValue"})).to match("AkeyaValueaNotherkeyAnotherValue")
    end
  end
  
  describe "authenticate" do
    let(:client) { SparkApi::Client.new({:api_key => "my_key", :api_secret => "my_secret"}) }
    subject do
      s = SparkApi::Authentication::ApiAuth.new(client)
      client.authenticator = s
      s
    end
    it "should authenticate the api credentials" do
      stub_request(:post, "https://api.sparkapi.com/#{SparkApi.version}/session").
                  with(:query => {:ApiKey => "my_key", :ApiSig => "c731cf2455fbc7a4ef937b2301108d7a"}).
                  to_return(:body => fixture("session.json"))
      subject.authenticate()
    end
    it "should raise an error when api credentials are invalid" do
      stub_request(:post, "https://api.sparkapi.com/#{SparkApi.version}/session").
                  with(:query => {:ApiKey => "my_key", :ApiSig => "c731cf2455fbc7a4ef937b2301108d7a"}).
                  to_return(:body => fixture("authentication_failure.json"), :status=>401)
      expect {subject.authenticate()}.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(401) }
    end
  end

  describe "authenticated?" do
    let(:session) { Object.new }
    it "should return true when session is active" do
      subject.session = session
      allow(session).to receive(:expired?) { false }
      expect(subject.authenticated?).to eq(true)
    end
    it "should return false when session is expired" do
      subject.session = session
      allow(session).to receive(:expired?) { true }
      expect(subject.authenticated?).to eq(false)
    end
    it "should return false when session is uninitialized" do
      expect(subject.authenticated?).to eq(false)
    end
  end

  describe "logout" do
    let(:session) { mock_session }
    let(:client) { Object.new }
    subject {SparkApi::Authentication::ApiAuth.new(client) }
    it "should logout when there is an active session" do
      logged_out = false
      subject.session = session
      allow(client).to receive(:delete).with("/session/1234") { logged_out = true }
      subject.logout
      expect(subject.session).to eq(nil)
      expect(logged_out).to eq(true)
    end
    it "should skip logging out when there is no active session information" do 
      allow(client).to receive(:delete) { raise "Should not be called" }
      expect(subject.logout).to eq(nil)
    end
  end
  
  # Since the request method is overly complex, the following tests just go through the whole stack
  # with some semi realistic requests.  Performing this type of test here should allow us to safely
  # mock out authentication for the rest of our unit tests and still have some decent coverage.
  describe "request" do
    let(:client) { SparkApi::Client.new({:api_key => "my_key", :api_secret => "my_secret"}) }
    let(:session) { mock_session }
    subject do
      s = SparkApi::Authentication::ApiAuth.new(client)
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
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/listings").
        with(:query => {
          :ApiSig => "1cb789831f8f4c6925dc708c93762a2c",
          :AuthToken => "1234"}.merge(args)).
        to_return(:body => fixture("listings/no_subresources.json"))
      subject.session = session
      expect(subject.request(:get, "/#{SparkApi.version}/listings", nil, args).status).to eq(200)
    end
    it "should handle a post request" do
      stub_auth_request
      args = {:ApiUser => "foobar"}
      contact = '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}'
      stub_request(:post, "#{SparkApi.endpoint}/#{SparkApi.version}/contacts").
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
      expect(subject.request(:post, "/#{SparkApi.version}/contacts", contact, args).status).to eq(201)
    end
    it "should incorporate any override_headers it is given while excluding them from the resulting request" do
      stub_auth_request
      args = {
        override_headers: {
          "Some-Header" => "Some-Value"
        },
        ApiUser: "foobar",
        some_other_param: "some_other_value"
      }
      body = "somerequestbodytext"
      stub_request(:post, "https://api.sparkapi.com/v1/someservice?ApiSig=856f5c036137c0cef5d4d223cd0f42be&ApiUser=foobar&AuthToken=1234&some_other_param=some_other_value").
        with(body: "somerequestbodytext", headers: args[:override_headers]).
        to_return(body: '{"D": {
          "Success": true,
          "Results": []
        }',
        status: 200)
        expect(subject.request(:post, "/#{SparkApi.version}/someservice", body, args).status).to eq(200)
    end
  end
  
  describe "sign" do
    it "should sign the auth parameters correctly" do
      sign_token = "my_secretApiKeymy_key"
      expect(subject.sign(sign_token)).to eq("c731cf2455fbc7a4ef937b2301108d7a")
    end
  end
  
  describe "sign_token" do
    let(:client) { SparkApi::Client.new({:api_key => "my_key", :api_secret => "my_secret"}) }
    subject {SparkApi::Authentication::ApiAuth.new(client) }
    it "should fully sign the token" do
      parms = {:AuthToken => "1234", :ApiUser => "CoolAsIce"}
      expect(subject.sign_token("/test", parms)).to eq("7bbe3384a8b64368357f8551cab271e3")
    end
  end
  
  context "when the server says the session is expired (even if we disagree)" do
    it "should reset the session and reauthenticate" do
      count = 0
      # Make sure the auth request goes out twice.
      stub_request(:post, "https://api.sparkapi.com/#{SparkApi.version}/session").
                  with(:query => {:ApiKey => "", :ApiSig => "806737984ab19be2fd08ba36030549ac"}).
                  to_return do |r|
                    count += 1
                    {:body => fixture("session.json")}
                  end
      # Fail the first time, but then return the correct value after reauthentication
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/listings/1234").
          with(:query => {
            :ApiSig => "554b6e2a3efec8719b782647c19d238d",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573",
            :ApiUser => "foobar",
            :_expand => "Documents"
          }).
          to_return(:body => fixture('errors/expired.json'), :status => 401).times(1).then.
          to_return(:body => fixture('listings/with_documents.json'))
      l = Listing.find('1234', :_expand => "Documents")
      
      expect(count).to eq(2)
      expect(SparkApi.client.session.expired?).to eq(false)
    end
  end
  
end
