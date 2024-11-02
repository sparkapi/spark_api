require './spec/spec_helper'

describe SparkApi::Client, "Client config"  do
  describe "default settings" do
    it "should return the proper defaults when called with no arguments" do
      expect(SparkApi.api_key).to be_nil
      expect(SparkApi.api_secret).to be_nil
      expect(SparkApi.version).to match("v1")
      expect(SparkApi.ssl_verify).to be true
      expect(SparkApi.auth_endpoint).to match("sparkplatform.com/openid")
      expect(SparkApi.endpoint).to match("api.sparkapi.com")
      expect(SparkApi.user_agent).to match(/Spark API Ruby Gem .*/)
      SparkApi.api_key = "my_api_key"
      expect(SparkApi.api_key).to match("my_api_key")
      expect(SparkApi.timeout).to eq(5)
      expect(SparkApi.request_id_chain).to be_nil
      expect(SparkApi.user_ip_address).to be_nil
      expect(SparkApi.middleware).to eq('spark_api')
      expect(SparkApi.verbose).to be false
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
                                    :request_id_chain => 'foobar',
                                    :user_ip_address => 'barfoo',
                                    :verbose => true)
 
      expect(client.api_key).to match("key_of_wade")
      expect(client.api_secret).to match("TopSecret")
      expect(client.api_user).to match("1234")
      expect(client.auth_endpoint).to match("https://login.wade.dev.fbsdata.com")
      expect(client.endpoint).to match("http://api.wade.dev.fbsdata.com")
      expect(client.version).to match("v1")
      expect(client.timeout).to eq(15)
      expect(client.request_id_chain).to eq('foobar')
      expect(client.user_ip_address).to eq('barfoo')
      expect(client.verbose).to be true
    end
    
    it "should allow unverified ssl certificates when verification is off" do
      client = SparkApi::Client.new(:auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "https://api.wade.dev.fbsdata.com",
                                    :ssl_verify => false)
      expect(client.ssl_verify).to be false
      expect(client.connection.ssl.verify).to be false
    end

    it "should allow restrict ssl certificates when verification is on" do
      client = SparkApi::Client.new(:auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "https://api.wade.dev.fbsdata.com",
                                    :ssl_verify => true)
      expect(client.ssl_verify).to be true
      expect(client.connection.ssl).to be_empty
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
      expect(oauth2_client.oauth2_provider).to be_a(SparkApi::Authentication::SimpleProvider)
    end

    it "should say oauth2_enabled? when it is" do
      expect(oauth2_client.oauth2_enabled?()).to be true
    end

    it "should say oauth2_enabled? is false" do
      client = SparkApi::Client.new(:api_key => "key_of_wade", 
                                    :api_secret => "TopSecret", 
                                    :callback => "http://wade.dev.fbsdata.com/callback",
                                    :auth_endpoint => "https://login.wade.dev.fbsdata.com",
                                    :endpoint => "http://api.wade.dev.fbsdata.com")
      expect(client.oauth2_enabled?()).to be false
    end

    it "should properly build a grant_uri from the endpoint" do
      expect(oauth2_client.grant_uri).to eq("http://api.wade.dev.fbsdata.com/v1/oauth2/grant")
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
        config.verbose = true
      end

      expect(SparkApi.api_key).to match("my_key")
      expect(SparkApi.api_secret).to match("my_secret")
      expect(SparkApi.api_user).to match("1234")
      expect(SparkApi.version).to match("veleventy")
      expect(SparkApi.endpoint).to match("test.api.sparkapi.com")
      expect(SparkApi.user_agent).to match("my useragent")
      expect(SparkApi.oauth2_enabled?()).to be false
      expect(SparkApi.timeout).to eq(15)
      expect(SparkApi.verbose).to be true
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
      expect(SparkApi.oauth2_enabled?()).to be true
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
      
      expect(SparkApi.api_key).to match("my_key")
      expect(SparkApi.request_id_chain).to eq("foobar")
      SparkApi.reset
      expect(SparkApi.api_key).to eq(SparkApi::Configuration::DEFAULT_API_KEY)
      expect(SparkApi.request_id_chain).to eq(SparkApi::Configuration::DEFAULT_REQUEST_ID_CHAIN)
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
          
      expect(SparkApi.client.get('/connections')[0]["SSL"]).to eq(false)
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
      expect(c.get('/connections')[0]["SSL"]).to eq(true)
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
      expect(WebMock).to have_requested(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers?ApiUser=foobar&ApiSig=717a066c4f4302c5ca9507e484db4812&AuthToken=c401736bf3d3f754f07c04e460e09573").
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
      expect(WebMock).to have_requested(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers?ApiUser=foobar&ApiSig=717a066c4f4302c5ca9507e484db4812&AuthToken=c401736bf3d3f754f07c04e460e09573").
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
      expect(c.connection.headers["Accept-Encoding"]).to be_nil
    end

    it "should set gzip header if compress option is set" do
      c = SparkApi::Client.new(:endpoint => "https://api.sparkapi.com",
        :compress => true) 
      expect(c.connection.headers["Accept-Encoding"]).to eq("gzip, deflate")
    end

    it "should set default timeout of 5 seconds" do
      c = SparkApi::Client.new(:endpoint => "https://sparkapi.com")
      expect(c.connection.options[:timeout]).to eq(5)
    end

    it "should set alternate timeout if specified" do
      c = SparkApi::Client.new(:endpoint => "https://sparkapi.com",
        :timeout => 15)
      expect(c.connection.options[:timeout]).to eq(15)
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
 
      expect(client.api_key).to match("key_of_cody")
      expect(client.api_secret).to match("TopSecret")
      expect(client.api_user).to match("1234")
      expect(client.endpoint).to match("http://api.coolio.dev.fbsdata.com")
      expect(client.timeout).to eq(15)
      expect(client.request_id_chain).to eq('foobar')
      expect(client.middleware).to eq('reso_api')
      expect(client.dictionary_version).to eq('1.6')
    end
  end
end

