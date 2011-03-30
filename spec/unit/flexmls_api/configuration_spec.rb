require './spec/spec_helper'

describe FlexmlsApi::Client, "Client config"  do
  after(:all) do
    reset_config
  end

  describe "default settings" do
    it "should return the proper defaults when called with no arguments" do
      FlexmlsApi.api_key.should be_nil
      FlexmlsApi.api_secret.should be_nil
      FlexmlsApi.version.should match("v1")
      FlexmlsApi.endpoint.should match("api.flexmls.com")

      FlexmlsApi.api_key = "my_api_key"
      FlexmlsApi.api_key.should match("my_api_key")
    end
  end

  describe "instance config" do
    it "should return a properly configured client" do
      client = FlexmlsApi::Client.new(:api_key => "key_of_wade", 
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
      FlexmlsApi.configure do |config|
        config.api_key = "my_key"
        config.api_secret = "my_secret"
        config.api_user = "1234"
        config.version = "veleventy"
        config.endpoint = "test.api.flexmls.com"
        config.user_agent = "my useragent"
      end

      FlexmlsApi.api_key.should match("my_key")
      FlexmlsApi.api_secret.should match("my_secret")
      FlexmlsApi.api_user.should match("1234")
      FlexmlsApi.version.should match("veleventy")
      FlexmlsApi.endpoint.should match("test.api.flexmls.com")
      FlexmlsApi.user_agent.should match("my useragent")

    end
    
    it "should reset" do
      FlexmlsApi.configure do |config|
        config.api_key = "my_key"
        config.api_secret = "my_secret"
        config.version = "veleventy"
        config.endpoint = "test.api.flexmls.com"
        config.user_agent = "my useragent"
      end
      
      FlexmlsApi.api_key.should match("my_key")
      FlexmlsApi.reset
      FlexmlsApi.api_key.should == FlexmlsApi::Configuration::DEFAULT_API_KEY
    
    end
  end

  describe "connections" do
    it "should use http by default" do
      stub_auth_request
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/connections").
          with(:query => {
            :ApiSig => "951e5ba0496b0758356d3cc7676f8b21",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": [{"SSL":false}]}}')
          
      FlexmlsApi.client.get('/connections')[0]["SSL"].should eq(false)

    end

    it "should use https when ssl is enabled" do
      stub_auth_request
      stub_request(:get, "https://api.flexmls.com/#{FlexmlsApi.version}/connections").
          with(:query => {
            :ApiSig => "951e5ba0496b0758356d3cc7676f8b21",
            :AuthToken => "c401736bf3d3f754f07c04e460e09573"
          }).
          to_return(:body => '{"D":{"Success": true,"Results": [{"SSL":true}]}}')
      c = FlexmlsApi::Client.new(:endpoint => "https://api.flexmls.com",
                                :ssl => true)
      c.get('/connections')[0]["SSL"].should eq(true)
    end
    
  end

end

