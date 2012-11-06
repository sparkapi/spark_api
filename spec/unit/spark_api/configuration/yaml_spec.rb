require './spec/spec_helper'

describe SparkApi::Configuration::YamlConfig, "Yaml Config"  do
  describe "api auth" do
    let(:api_file){ "spec/config/spark_api/test_key.yml" }
    it "should load a configured api key for development" do
      subject.stub(:env){ {} }
      subject.api_env.should eq("development")
      subject.load_file(api_file)
      subject.oauth2?.should eq(false)
      subject.ssl_verify?.should eq(false)
      subject.api_key.should eq("demo_key")
      subject.api_secret.should eq("t3sts3cr3t")
      subject.endpoint.should eq("https://developers.sparkapi.com")
      subject.name.should eq("test_key")
      subject.client_keys.keys.should =~ [:api_key, :api_secret, :endpoint, :ssl_verify]
      subject.oauth2_keys.keys.should eq([])
    end
    it "should load a configured api key for production" do
      subject.stub(:env){ {"SPARK_API_ENV" => "production"} }
      subject.api_env.should eq("production")
      subject.load_file(api_file)
      subject.oauth2?.should eq(false)
      subject.api_key.should eq("prod_demo_key")
      subject.api_secret.should eq("prod_t3sts3cr3t")
      subject.endpoint.should eq("https://api.sparkapi.com")
    end
    it "should raise an error for a bad configuration" do
      subject.stub(:env){ {} }
      expect { subject.load_file("spec/config/spark_api/some_random_key.yml")}.to raise_error
      subject.stub(:env){ {"RAILS_ENV" => "fake_env"} }
      expect { subject.load_file(api_file)}.to raise_error
    end
  end
  describe "oauth2" do
    let(:oauth2_file){ "spec/config/spark_api/test_oauth.yml" }
    it "should load a configured api key for development" do
      subject.stub(:env){ {} }
      subject.api_env.should eq("development")
      subject.load_file(oauth2_file)
      subject.oauth2?.should eq(true)
      subject.authorization_uri.should eq("https://developers.sparkplatform.com/oauth2")
      subject.access_uri.should eq("https://developers.sparkapi.com/v1/oauth2/grant")
      subject.redirect_uri.should eq("http://localhost/oauth2/callback")
      subject.client_id.should eq("developmentid124nj4qu3pua")
      subject.client_secret.should eq("developmentsecret4orkp29f")
      subject.endpoint.should eq("https://developers.sparkapi.com")
      subject.oauth2_provider.should eq("SparkApi::TestOAuth2Provider")
      subject.name.should eq("test_oauth")
      subject.client_keys.keys.should =~ [:endpoint, :oauth2_provider]
      subject.oauth2_keys.keys.should =~ [:authorization_uri, :client_id, :access_uri, :client_secret, :redirect_uri]
    end
    it "should load a configured api key for production" do
      subject.stub(:env){ {"SPARK_API_ENV" => "production"} }
      subject.api_env.should eq("production")
      subject.load_file(oauth2_file)
      subject.oauth2?.should eq(true)
      subject.authorization_uri.should eq("https://sparkplatform.com/oauth2")
      subject.access_uri.should eq("https://api.sparkapi.com/v1/oauth2/grant")
      subject.redirect_uri.should eq("http://localhost/oauth2/callback")
      subject.client_id.should eq("production1id124nj4qu3pua")
      subject.client_secret.should eq("productionsecret4orkp29fv")
      subject.endpoint.should eq("https://api.sparkapi.com")
      subject.oauth2_provider.should eq(subject.class::DEFAULT_OAUTH2_PROVIDER)
      subject.name.should eq("test_oauth")
    end
    
    it "should list available keys" do
      SparkApi::Configuration::YamlConfig.stub(:config_path) { "spec/config/spark_api" }
      subject.class.config_keys.should =~ ["test_key", "test_oauth", "test_single_session_oauth"]
    end
  end
end
