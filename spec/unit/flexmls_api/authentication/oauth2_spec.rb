require './spec/spec_helper'

# Lightweight example of an oauth2 provider used by the ruby client.
class TestOAuth2Provider < FlexmlsApi::Authentication::BaseOAuth2Provider
  
  def initialize
    @authorization_uri = "https://test.fbsdata.com/r/oauth2"
    @access_uri = "https://api.test.fbsdata.com/v1/oauth2/grant"
    @redirect_uri = "https://exampleapp.fbsdata.com/oauth-callback"
    @client_id="example-id"
    @client_secret="example-password"    
    @session_cache = {}
  end
  
  def redirect(url)
    # User redirected to url, signs in, and gets code sent to callback
    self.code="my_code"
  end
  
  def load_session()
    @session_cache["test_user_session"]
  end
  
  def save_session(session)
    @session_cache["test_user_session"] = session
    nil
  end
  
end

describe FlexmlsApi::Authentication::OAuth2  do
  let(:provider) { TestOAuth2Provider.new() }
  let(:client) { FlexmlsApi::Client.new({:authentication_mode => FlexmlsApi::Authentication::OAuth2,:oauth2_provider => provider}) }
  subject {client.authenticator }  
  # Make sure the client boostraps the right plugin based on configuration.
  describe "plugin" do
    it "should load the oauth2 authenticator" do
      client.authenticator.class.should eq(FlexmlsApi::Authentication::OAuth2)
    end
  end
  describe "authenticate" do
    it "should authenticate the api credentials" do
      subject.authenticate.should eq(nil)
      
      stub_request(:post, provider.access_uri).
        with(:query => {
            :client_id => provider.client_id,
            :client_secret => provider.client_secret,
            :grant_type => "authorization_code",
            :redirect_uri => provider.redirect_uri,
            :code => provider.code
          }
        ).
        to_return(:body => fixture("oauth2_access.json"), :status=>200)
      
      subject.authenticate.access_token.should eq("04u7h-4cc355-70k3n")
      
    end
    
    it "should raise an error when api credentials are invalid" do
      subject.authenticate.should eq(nil)
      stub_request(:post, provider.access_uri).
        with(:query => {
            :client_id => provider.client_id,
            :client_secret => provider.client_secret,
            :grant_type => "authorization_code",
            :redirect_uri => provider.redirect_uri,
            :code => provider.code
          }
        ).
        to_return(:body => fixture("oauth2_error.json"), :status=>400)
      expect {subject.authenticate()}.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
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
    let(:session) { mock_oauth_session }
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
  
  describe "request" do
    let(:session) { mock_oauth_session }
    it "should handle a get request" do
      subject.session = session
      args = {
        :_limit => '10',
        :_page => '1',
        :_pagination => '1'
      }
      c = stub_request(:get, "https://api.flexmls.com/#{FlexmlsApi.version}/listings").
        with(:query => {:access_token => "1234"}.merge(args)).
        to_return(:body => fixture("listing_no_subresources.json"))
      subject.session = session
      subject.request(:get, "/#{FlexmlsApi.version}/listings", nil, args).status.should eq(200)
    end
    it "should handle a post request" do
      subject.session = session
      args = {}
      contact = '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}'
      stub_request(:post, "https://api.flexmls.com/#{FlexmlsApi.version}/contacts").
        with(:query => {:access_token => "1234"}.merge(args),
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
end
