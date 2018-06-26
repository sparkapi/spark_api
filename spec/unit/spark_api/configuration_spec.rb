require './spec/spec_helper'

describe SparkApi::Client, "Client config"  do
  describe "default settings" do
    it "should return the proper defaults when called with no arguments" do
      SparkApi.api_key.should be_nil
      SparkApi.api_secret.should be_nil
      SparkApi.version.should match("v1")
      SparkApi.ssl_verify.should be true
      SparkApi.auth_endpoint.should match("sparkplatform.com/openid")
      SparkApi.endpoint.should match("api.sparkapi.com")
      SparkApi.user_agent.should match(/Spark API Ruby Gem .*/)
      SparkApi.api_key = "my_api_key"
      SparkApi.api_key.should match("my_api_key")
      SparkApi.timeout.should eq(5)
      SparkApi.request_id_chain.should be_nil
      SparkApi.middleware.should eq('spark_api')
    end
  end

  describe "instance config" do
    it "should return a properly configured client" do
      client = SparkApi::Client.new(:api_key => "key_of_wade", 
                                    :api_secret => "TopSecret", 
                                    :api_user => "1234",
                                    :auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "http://api.wade.dev.fbsdata.com",
                                    :timeout => 15,
                                    :request_id_chain => 'foobar')
 
      client.api_key.should match("key_of_wade")
      client.api_secret.should match("TopSecret")
      client.api_user.should match("1234")
      client.auth_endpoint.should match("https://login.wade.dev.fbsdata.com")
      client.endpoint.should match("http://api.wade.dev.fbsdata.com")
      client.version.should match("v1")
      client.timeout.should eq(15)
      client.request_id_chain.should eq('foobar')
    end
    
    it "should allow unverified ssl certificates when verification is off" do
      client = SparkApi::Client.new(:auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "https://api.wade.dev.fbsdata.com",
                                    :ssl_verify => false)
      client.ssl_verify.should be false
      client.connection.ssl.verify.should be false
    end

    it "should allow restrict ssl certificates when verification is on" do
      client = SparkApi::Client.new(:auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "https://api.wade.dev.fbsdata.com",
                                    :ssl_verify => true)
      client.ssl_verify.should be true
      client.connection.ssl.should be_empty
    end
  end

  describe "oauth2 instance configuration" do
    let(:oauth2_client) do
      SparkApi::Client.new(:api_key => "key_of_wade", 
                           :api_secret => "TopSecret", 
                           :callback => "http://wade.dev.fbsdata.com/callback",
                           :auth_endpoint => "https://login.wade.dev.fbsdata.com",
                           :endpoint => "http://api.wade.dev.fbsdata.com",
                           :authentication_mode => SparkApi::Authentication::OAuth2)
    end
    
    it "should convert the configuration to oauth2 when specified" do
      oauth2_client.oauthify!
      oauth2_client.oauth2_provider.should be_a(SparkApi::Authentication::SimpleProvider)
    end

    it "should say oauth2_enabled? when it is" do
      oauth2_client.oauth2_enabled?().should be true
    end

    it "should say oauth2_enabled? is false" do
      client = SparkApi::Client.new(:api_key => "key_of_wade", 
                                    :api_secret => "TopSecret", 
                                    :callback => "http://wade.dev.fbsdata.com/callback",
                                    :auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "http://api.wade.dev.fbsdata.com")
      client.oauth2_enabled?().should be false
    end

    it "should properly build a grant_uri from the endpoint" do
      oauth2_client.grant_uri.should eq("http://api.wade.dev.fbsdata.com/v1/oauth2/grant")
    end
  end

  describe "block config" do
    it "should correctly set up the client" do
      SparkApi.configure do |config|
        config.api_key = "my_key"
        config.api_secret = "my_secret"
        config.api_user = "1234"
        config.version = "veleventy"
        config.endpoint = "test.api.sparkapi.com"
        config.user_agent = "my useragent"
        config.timeout = 15
      end

      SparkApi.api_key.should match("my_key")
      SparkApi.api_secret.should match("my_secret")
      SparkApi.api_user.should match("1234")
      SparkApi.version.should match("veleventy")
      SparkApi.endpoint.should match("test.api.sparkapi.com")
      SparkApi.user_agent.should match("my useragent")
      SparkApi.oauth2_enabled?().should be false
      SparkApi.timeout.should eq(15)
    end

    it "should correctly set up the client for oauth2" do
      SparkApi.configure do |config|
        config.api_key = "my_key"
        config.api_secret = "my_secret"
        config.callback = "http://wade.dev.fbsdata.com/callback",
        config.auth_endpoint = "https://login.wade.dev.fbsdata.com",
        config.endpoint = "test.api.sparkapi.com"
        config.user_agent = "my useragent"
        config.authentication_mode = SparkApi::Authentication::OAuth2
      end
      SparkApi.oauth2_enabled?().should be true
    end
    
    it "should reset" do
      SparkApi.configure do |config|
        config.api_key = "my_key"
        config.api_secret = "my_secret"
        config.version = "veleventy"
        config.endpoint = "test.api.sparkapi.com"
        config.user_agent = "my useragent"
        config.request_id_chain = 'foobar'
      end
      
      SparkApi.api_key.should match("my_key")
      SparkApi.request_id_chain.should eq("foobar")
      SparkApi.reset
      SparkApi.api_key.should == SparkApi::Configuration::DEFAULT_API_KEY
      SparkApi.request_id_chain.should SparkApi::Configuration::DEFAULT_REQUEST_ID_CHAIN
    
    end
  end

  describe "connections" do
    it "should use http by default" do
      stub_auth_request
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/connections").
          with(:query => {
            :ApiSig => "951e5ba0496b0758356d3cc7676f8b21",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": [{"SSL":false}]}}')
          
      SparkApi.client.get('/connections')[0]["SSL"].should eq(false)
    end

    it "should use https when ssl is enabled" do
      stub_auth_request
      stub_request(:get, "https://api.sparkapi.com/#{SparkApi.version}/connections").
          with(:query => {
            :ApiSig => "951e5ba0496b0758356d3cc7676f8b21",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": [{"SSL":true}]}}')
          
      c = SparkApi::Client.new(:endpoint => "https://api.sparkapi.com", :ssl => true)
      c.get('/connections')[0]["SSL"].should eq(true)
    end
    
    it "should have correct headers based on configuration" do
      reset_config
      stub_auth_request
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers").
          with(:query => {
            :ApiUser => "foobar",
            :ApiSig => "717a066c4f4302c5ca9507e484db4812",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": []}}')
      SparkApi.configure do |config|
        config.user_agent = "my useragent"
      end
      SparkApi.client.get '/headers'
      WebMock.should have_requested(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers?ApiUser=foobar&ApiSig=717a066c4f4302c5ca9507e484db4812&AuthToken=c401736bf3d3f754f07c04e460e09573").
        with(:headers => {
          'User-Agent' => SparkApi::Configuration::DEFAULT_USER_AGENT,
          SparkApi::Configuration::X_SPARK_API_USER_AGENT => "my useragent",
          'Accept'=>'application/json', 
          'Content-Type'=>'application/json'
        })
    end

    it "should pass along the request_id_chain header if set" do
      reset_config
      stub_auth_request
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers").
          with(:query => {
            :ApiUser => "foobar",
            :ApiSig => "717a066c4f4302c5ca9507e484db4812",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": []}}')
      SparkApi.configure do |config|
        config.user_agent = "my useragent"
        config.request_id_chain = 'foobar'
      end
      SparkApi.client.get '/headers'
      WebMock.should have_requested(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers?ApiUser=foobar&ApiSig=717a066c4f4302c5ca9507e484db4812&AuthToken=c401736bf3d3f754f07c04e460e09573").
        with(:headers => {
          'User-Agent' => SparkApi::Configuration::DEFAULT_USER_AGENT,
          SparkApi::Configuration::X_SPARK_API_USER_AGENT => "my useragent",
          'Accept'=>'application/json', 
          'Content-Type'=>'application/json',
          'X-Request-Id-Chain' => 'foobar'
        })
    end

    it "should not set gzip header by default" do
      c = SparkApi::Client.new(:endpoint => "https://sparkapi.com")
      c.connection.headers["Accept-Encoding"].should be_nil
    end

    it "should set gzip header if compress option is set" do
      c = SparkApi::Client.new(:endpoint => "https://api.sparkapi.com",
        :compress => true) 
      c.connection.headers["Accept-Encoding"].should eq("gzip, deflate")
    end

    it "should set default timeout of 5 seconds" do
      c = SparkApi::Client.new(:endpoint => "https://sparkapi.com")
      c.connection.options[:timeout].should eq(5)
    end

    it "should set alternate timeout if specified" do
      c = SparkApi::Client.new(:endpoint => "https://sparkapi.com",
        :timeout => 15)
      c.connection.options[:timeout].should eq(15)
    end
  end

  describe "RESO configuration" do
    it "should return a properly configured client" do
      client = SparkApi::Client.new(:api_key => "key_of_cody", 
                                    :api_secret => "TopSecret", 
                                    :api_user => "1234",
                                    :endpoint => "http://api.coolio.dev.fbsdata.com",
                                    :timeout => 15,
                                    :request_id_chain => 'foobar',
                                    :middleware => 'reso_api',
                                    :dictionary_version => '1.6')
 
      client.api_key.should match("key_of_cody")
      client.api_secret.should match("TopSecret")
      client.api_user.should match("1234")
      client.endpoint.should match("http://api.coolio.dev.fbsdata.com")
      client.timeout.should eq(15)
      client.request_id_chain.should eq('foobar')
      client.middleware.should eq('reso_api')
      client.dictionary_version.should eq('1.6')
    end
  end
end

