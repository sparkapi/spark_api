require 'spec_helper'

describe SparkApi::Authentication::OAuth2  do
  before(:all) { SparkApi.reset } # dump api user stuff from other tests
  let(:provider) { TestOAuth2Provider.new() }
  let(:client) { SparkApi::Client.new({
    :authentication_mode => SparkApi::Authentication::OAuth2,
    :oauth2_provider => provider,
    :sparkbar_uri => "https://test.sparkplatform.com/appbar/authorize"}) }
  subject {client.authenticator }  
  # Make sure the client boostraps the right plugin based on configuration.
  describe "plugin" do
    it "should load the oauth2 authenticator" do
      expect(client.authenticator.class).to eq(SparkApi::Authentication::OAuth2)
    end
  end
  describe "authenticate" do
    it "should authenticate the api credentials" do
      stub_request(:post, provider.access_uri).
        with(:body => 
          '{"client_id":"example-id","client_secret":"example-password","code":"my_code","grant_type":"authorization_code","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback"}' 
        ).
        to_return(:body => fixture("oauth2/access.json"), :status=>200)
      expect(subject.authenticate.access_token).to eq("04u7h-4cc355-70k3n")
      expect(subject.authenticate.expires_in).to eq(57600)
    end
    
    it "should raise an error when api credentials are invalid" do
      s=stub_request(:post, provider.access_uri).
        with(:body => 
          '{"client_id":"example-id","client_secret":"example-password","code":"my_code","grant_type":"authorization_code","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback"}'
        ).
        to_return(:body => fixture("oauth2/error.json"), :status=>400)
      expect {subject.authenticate()}.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(400) }
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
    let(:session) { mock_oauth_session }
    it "should logout when there is an active session" do
      subject.session = session
      subject.logout
      expect(subject.session).to eq(nil)
    end
    it "should skip logging out when there is no active session information" do 
      allow(client).to receive(:delete) { raise "Should not be called" }
      expect(subject.logout).to eq(nil)
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
      c = stub_request(:get, "https://api.sparkapi.com/#{SparkApi.version}/listings").
        with(:query => args).
        to_return(:body => fixture("listings/no_subresources.json"))
      subject.session = session
      expect(subject.request(:get, "/#{SparkApi.version}/listings", nil, args).status).to eq(200)
    end
    it "should handle a post request" do
      subject.session = session
      args = {}
      contact = '{"D":{"Contacts":[{"DisplayName":"Contact Four","PrimaryEmail":"contact4@fbsdata.com"}]}}'
      stub_request(:post, "https://api.sparkapi.com/#{SparkApi.version}/contacts").
        with(:body => contact).
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
      subject.session = session
      args = {
        override_headers: {
          "Some-Header" => "Some-Value"
        },
        some_other_param: "some_other_value"
      }
      body = "somerequestbodytext"
      stub_request(:post, "https://api.sparkapi.com/#{SparkApi.version}/someservice?some_other_param=some_other_value").
        with(body: body, headers: args[:override_headers]).
        to_return(body: '{"D": {
          "Success": true,
          "Results": []
        }',
        status: 200)
        expect(subject.request(:post, "/#{SparkApi.version}/someservice", body, args).status).to eq(200)
    end
  end
  
  describe "sparkbar_token" do
    let(:session) { mock_oauth_session }
    it "should fetch a sparkbar token" do
      c = stub_request(:post, "https://test.sparkplatform.com/appbar/authorize").
        with(:body => "access_token=#{session.access_token}").
        to_return(:body => '{"token":"sp4rkb4rt0k3n"}')
      subject.session = session
      expect(subject.sparkbar_token).to eq("sp4rkb4rt0k3n")
    end
    it "should raise an error on missing sparkbar token" do
      c = stub_request(:post, "https://test.sparkplatform.com/appbar/authorize").
        with(:body => "access_token=#{session.access_token}").
        to_return(:body => '{"foo":"bar"}')
      subject.session = session
      expect {subject.sparkbar_token }.to raise_error(SparkApi::ClientError)
    end
  end

  context "with an expired session" do
    context "and a valid refresh token" do
      it "should reset the session and reauthenticate" do
        count = 0
        refresh_count = 0
        stub_request(:post, provider.access_uri).
          with(:body => 
            '{"client_id":"example-id","client_secret":"example-password","code":"my_code","grant_type":"authorization_code","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback"}'
          ).to_return do
            count += 1
            {:body => fixture("oauth2/access_with_old_refresh.json"), :status=>200}
          end
        stub_request(:post, provider.access_uri).
          with(:body => 
            '{"client_id":"example-id","client_secret":"example-password","grant_type":"refresh_token","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback","refresh_token":"0ld-r3fr35h-70k3n"}'
          ).to_return do
            refresh_count += 1
            {:body => fixture("oauth2/access_with_refresh.json"), :status=>200}
          end
        # Make sure the auth request goes out twice.
        # Fail the first time, but then return the correct value after reauthentication
        stub_request(:get, "https://api.sparkapi.com/#{SparkApi.version}/listings/1234").
          to_return(:body => fixture('errors/expired.json'), :status => 401).times(1).then.
          to_return(:body => fixture('listings/with_documents.json'))
        client.get("/listings/1234")
        expect(count).to eq(1)
        expect(refresh_count).to eq(1)
        expect(client.session.expired?).to eq(false)
      end
    end
    context "and an invalid refresh token" do
      it "should reset the session and reauthenticate" do
        count = 0
        stub_request(:post, provider.access_uri).
          with(:body =>
            '{"client_id":"example-id","client_secret":"example-password","code":"my_code","grant_type":"authorization_code","redirect_uri":"https://exampleapp.fbsdata.com/oauth-callback"}' 
          ).to_return do
            count += 1
            {:body => fixture("oauth2/access.json"), :status=>200}
          end
        # Make sure the auth request goes out twice.
        # Fail the first time, but then return the correct value after reauthentication
        stub_request(:get, "https://api.sparkapi.com/#{SparkApi.version}/listings/1234").
          to_return(:body => fixture('errors/expired.json'), :status => 401).times(1).then.
          to_return(:body => fixture('listings/with_documents.json'))
              
        client.get("/listings/1234")
        expect(count).to eq(2)
        expect(client.session.expired?).to eq(false)
      end
    end
  end
end

describe SparkApi::Authentication::OpenIdOAuth2Hybrid do
  let(:provider) do 
    SparkApi::Authentication::SimpleProvider.new({
      :access_uri    => "https://mygrantsite.com",
      :client_id     => "mykey",
      :client_secret => "mysecret",
      :authorization_uri => "https://sparkplatform.com",
      :redirect_uri  => "https://mycallback.com"
    })
  end
  let(:client) do 
    SparkApi::Client.new({:authentication_mode => SparkApi::Authentication::OpenIdOAuth2Hybrid,:oauth2_provider => provider}) 
  end
  describe "plugin" do
    it "should load the hybrid authenticator" do
      expect(client.authenticator.class).to eq(SparkApi::Authentication::OpenIdOAuth2Hybrid)
    end
  end

  describe "#authorization_url" do
    it "should include combined flow parameter" do
      expect(client.authenticator.authorization_url).to match("openid.spark.combined_flow=true")
    end
    it "should allow custom parameters" do
      expect(client.authenticator.authorization_url({"joshua" => "iscool"})).to match("joshua=iscool")
    end
  end
end

describe SparkApi::Authentication::OpenId do
  let(:provider) do 
    SparkApi::Authentication::SimpleProvider.new({
      :access_uri    => "https://mygrantsite.com",
      :client_id     => "mykey",
      :client_secret => "mysecret",
      :authorization_uri => "https://sparkplatform.com",
      :redirect_uri  => "https://mycallback.com"
    })
  end

  let(:client) {SparkApi::Client.new({:authentication_mode => SparkApi::Authentication::OpenId, :oauth2_provider => provider}) }

  describe "plugin" do
    it "should not include combined flow parameter" do
      expect(client.authenticator.authorization_url).not_to match("openid.spark.combined_flow=true")
    end
    it "should load the oauth2 authenticator" do
      expect(client.authenticator.class).to eq(SparkApi::Authentication::OpenId)
    end
  end

  describe "#authorization_url" do
    it "should allow custom parameters" do
      expect(client.authenticator.authorization_url({"joshua" => "iscool"})).to match("joshua=iscool")
    end
  end

  describe "forbidden methods" do
    it "should not allow authentication" do
      expect {
        client.authenticate
      }.to raise_error(RuntimeError)
    end
  end
end

describe SparkApi::Authentication::BaseOAuth2Provider  do
  context "session_timeout" do
    it "should provide a default" do
      expect(subject.session_timeout).to eq(86400)
    end
    describe TestOAuth2Provider do
      subject { TestOAuth2Provider.new }
      it "should be able to override the session timeout" do
        expect(subject.session_timeout).to eq(57600)
      end
    end
  end
end

describe "password authentication" do
  let(:provider) { TestCLIOAuth2Provider.new() }
  let(:client) { SparkApi::Client.new({:authentication_mode => SparkApi::Authentication::OAuth2,:oauth2_provider => provider}) }
  subject {client.authenticator }  
  it "should authenticate the api credentials with username and password" do
    stub_request(:post, provider.access_uri).
      with(:body =>
        '{"client_id":"example-id","client_secret":"example-secret","grant_type":"password","password":"example-password","username":"example-user"}' 
      ).to_return(:body => fixture("oauth2/access.json"), :status=>200)
    expect(subject.authenticate.access_token).to eq("04u7h-4cc355-70k3n")
    expect(subject.authenticate.expires_in).to eq(60)
  end
end
describe SparkApi::Authentication::OAuth2Impl  do
  it "should load a provider" do
    example = "SparkApi::Authentication::OAuth2Impl::CLIProvider"
    expect(SparkApi::Authentication::OAuth2Impl.load_provider(example,{}).class.to_s).to eq(example)
    prefix = "::#{example}"
    expect(SparkApi::Authentication::OAuth2Impl.load_provider(prefix,{}).class.to_s).to eq(example)
    bad_example = "Derp::Derp::Derp::DerpProvider"
    expect{expect(SparkApi::Authentication::OAuth2Impl.load_provider(bad_example,{}).class.to_s).to eq(bad_example)}.to raise_error(ArgumentError)
  end

end

describe SparkApi::Authentication::OAuthSession do
  it "should serialize to json" do
    args = {
      "access_token" => "abc", 
      "expires_in" => 3600, 
      "refresh_token" => "123", 
      "refresh_timeout" => 10000,
      "start_time" => "2012-01-01T00:00:00+00:00"
    }
    session = SparkApi::Authentication::OAuthSession.new(args)
    expect(session.start_time).to eq(DateTime.parse(args["start_time"]))
    expect(JSON.parse(session.to_json)).to eq(args)
  end

  it "should accept symbolized parameters" do
    args = {
      :access_token => "abc", 
      :expires_in => 3600, 
      :refresh_token => "123", 
      :refresh_timeout => 10000,
      :start_time => "2012-01-01T00:00:00+00:00"
    }
    session = SparkApi::Authentication::OAuthSession.new(args)
    expect(session.start_time).to eq(DateTime.parse(args[:start_time]))
    expect(JSON.parse(session.to_json)).to eq(JSON.parse(args.to_json))
  end

  it "should not expire if expires_in is nil" do
    session = SparkApi::Authentication::OAuthSession.new
    expect(session.expired?).to eq(false)
  end
end
