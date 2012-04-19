require './spec/spec_helper'

describe SparkApi::Client, "Client config"  do
  after(:all) do
    reset_config
  end

  describe "default settings" do
    it "should return the proper defaults when called with no arguments" do
      SparkApi.api_key.should be_nil
      SparkApi.api_secret.should be_nil
      SparkApi.version.should match("v1")
      SparkApi.endpoint.should match("api.sparkapi.com")
      SparkApi.user_agent.should match(/Spark API Ruby Gem .*/)
      SparkApi.api_key = "my_api_key"
      SparkApi.api_key.should match("my_api_key")
    end
  end

  describe "instance config" do
    it "should return a properly configured client" do
      client = SparkApi::Client.new(:api_key => "key_of_wade", 
                                      :api_secret => "TopSecret", 
                                      :api_user => "1234",
                                      :endpoint => "http://api.wade.dev.fbsdata.com")
 
      client.api_key.should match("key_of_wade")
      client.api_secret.should match("TopSecret")
      client.api_user.should match("1234")
      client.endpoint.should match("http://api.wade.dev.fbsdata.com")
      client.version.should match("v1")
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
      end

      SparkApi.api_key.should match("my_key")
      SparkApi.api_secret.should match("my_secret")
      SparkApi.api_user.should match("1234")
      SparkApi.version.should match("veleventy")
      SparkApi.endpoint.should match("test.api.sparkapi.com")
      SparkApi.user_agent.should match("my useragent")

    end
    
    it "should reset" do
      SparkApi.configure do |config|
        config.api_key = "my_key"
        config.api_secret = "my_secret"
        config.version = "veleventy"
        config.endpoint = "test.api.sparkapi.com"
        config.user_agent = "my useragent"
      end
      
      SparkApi.api_key.should match("my_key")
      SparkApi.reset
      SparkApi.api_key.should == SparkApi::Configuration::DEFAULT_API_KEY
    
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
      stub_auth_request
      stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers").
          with(:query => {
            :ApiSig => "6f0cfef263e0bfe7a9ae1f60063a8ad9",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": []}}')
      SparkApi.reset
      SparkApi.configure do |config|
        config.user_agent = "my useragent"
      end
      SparkApi.client.get '/headers'
      WebMock.should have_requested(:get, "#{SparkApi.endpoint}/#{SparkApi.version}/headers?ApiSig=6f0cfef263e0bfe7a9ae1f60063a8ad9&AuthToken=c401736bf3d3f754f07c04e460e09573").
        with(:headers => {
          'User-Agent' => SparkApi::Configuration::DEFAULT_USER_AGENT,
          SparkApi::Configuration::X_SPARK_API_USER_AGENT => "my useragent",
          'Accept'=>'application/json', 
          'Content-Type'=>'application/json'
        })
    end
    
  end

end

