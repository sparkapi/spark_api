require './spec/spec_helper'
require './spec/oauth2_helper'

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
      stub_request(:post, provider.access_uri).
        with(:body => 
            '{"code":"my_code","client_secret":"example-password","client_id":"example-id","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback","grant_type":"authorization_code"}' 
        ).
        to_return(:body => fixture("oauth2/access.json"), :status=>200)
      subject.authenticate.access_token.should eq("04u7h-4cc355-70k3n")
      subject.authenticate.expires_in.should eq(7200)
    end
    
    it "should raise an error when api credentials are invalid" do
      s=stub_request(:post, provider.access_uri).
        with(:body => 
             '{"code":"my_code","client_secret":"example-password","client_id":"example-id","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback","grant_type":"authorization_code"}'
        ).
        to_return(:body => fixture("oauth2/error.json"), :status=>400)
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
      subject.session = session
      subject.logout
      subject.session.should eq(nil)
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
        with(:query => args).
        to_return(:body => fixture("listings/no_subresources.json"))
      subject.session = session
      subject.request(:get, "/#{FlexmlsApi.version}/listings", nil, args).status.should eq(200)
    end
    it "should handle a post request" do
      subject.session = session
      args = {}
      contact = '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}'
      stub_request(:post, "https://api.flexmls.com/#{FlexmlsApi.version}/contacts").
        with(:body => contact).
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

  context "with an expired session" do
    context "and a valid refresh token" do
      it "should reset the session and reauthenticate" do
        count = 0
        refresh_count = 0
        stub_request(:post, provider.access_uri).
          with(:body => '{"code":"my_code","client_secret":"example-password","client_id":"example-id","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback","grant_type":"authorization_code"}'). 
          to_return do
            count += 1
            {:body => fixture("oauth2/access_with_old_refresh.json"), :status=>200}
          end
        stub_request(:post, provider.access_uri).
          with(:body => '{"client_id":"example-id","client_secret":"example-password","grant_type":"refresh_token","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback","refresh_token":"0ld-r3fr35h-70k3n"}'). 
          to_return do
            refresh_count += 1
            {:body => fixture("oauth2/access_with_refresh.json"), :status=>200}
          end
        # Make sure the auth request goes out twice.
        # Fail the first time, but then return the correct value after reauthentication
        stub_request(:get, "https://api.flexmls.com/#{FlexmlsApi.version}/listings/1234").
            to_return(:body => fixture('errors/expired.json'), :status => 401).times(1).then.
            to_return(:body => fixture('listings/with_documents.json'))
        client.get("/listings/1234")
        count.should eq(1)
        refresh_count.should eq(1)
        client.session.expired?.should eq(false)
      end
    end
    context "and an invalid refresh token" do
      it "should reset the session and reauthenticate" do
        count = 0
        stub_request(:post, provider.access_uri).
          with(:body => '{"code":"my_code","client_secret":"example-password","client_id":"example-id","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback","grant_type":"authorization_code"}'). 
          to_return do
            count += 1
            {:body => fixture("oauth2/access.json"), :status=>200}
          end
        # Make sure the auth request goes out twice.
        # Fail the first time, but then return the correct value after reauthentication
        stub_request(:get, "https://api.flexmls.com/#{FlexmlsApi.version}/listings/1234").
            to_return(:body => fixture('errors/expired.json'), :status => 401).times(1).then.
            to_return(:body => fixture('listings/with_documents.json'))
              
        client.get("/listings/1234")
        count.should eq(2)
        client.session.expired?.should eq(false)
      end
    end
  end
end

describe FlexmlsApi::Authentication::BaseOAuth2Provider  do
  context "session_timeout" do
    it "should provide a default" do
      subject.session_timeout.should eq(86400)
    end
    describe TestOAuth2Provider do
      subject { TestOAuth2Provider.new }
      it "should be able to override the session timeout" do
        subject.session_timeout.should eq(7200)
      end
    end
  end
end

describe "password authentication" do
  let(:provider) { TestCLIOAuth2Provider.new() }
  let(:client) { FlexmlsApi::Client.new({:authentication_mode => FlexmlsApi::Authentication::OAuth2,:oauth2_provider => provider}) }
  subject {client.authenticator }  
  it "should authenticate the api credentials with username and password" do
    stub_request(:post, provider.access_uri).
      with(:body => 
        '{"username":"example-user","client_secret":"example-secret","client_id":"example-id","password":"example-password","grant_type":"password"}' 
      ).
      to_return(:body => fixture("oauth2/access.json"), :status=>200)
    subject.authenticate.access_token.should eq("04u7h-4cc355-70k3n")
    subject.authenticate.expires_in.should eq(60)
  end
end
