require './spec/spec_helper'

describe SparkApi::Configuration::YamlConfig, "Yaml Config"  do
  describe "api auth" do
    let(:api_file){ "spec/config/spark_api/test_key.yml" }
    it "should load a configured api key for development" do
      allow(subject).to receive(:env){ {} }
      expect(subject.api_env).to eq("development")
      subject.load_file(api_file)
      expect(subject.oauth2?).to eq(false)
      expect(subject.ssl_verify?).to eq(false)
      expect(subject.api_key).to eq("demo_key")
      expect(subject.api_secret).to eq("t3sts3cr3t")
      expect(subject.endpoint).to eq("https://developers.sparkapi.com")
      expect(subject.name).to eq("test_key")
      expect(subject.client_keys.keys).to match_array([:api_key, :api_secret, :endpoint, :ssl_verify])
      expect(subject.oauth2_keys.keys).to eq([])
    end
    it "should load a configured api key for production" do
      allow(subject).to receive(:env){ {"SPARK_API_ENV" => "production"} }
      expect(subject.api_env).to eq("production")
      subject.load_file(api_file)
      expect(subject.oauth2?).to eq(false)
      expect(subject.api_key).to eq("prod_demo_key")
      expect(subject.api_secret).to eq("prod_t3sts3cr3t")
      expect(subject.endpoint).to eq("https://api.sparkapi.com")
    end
    it "should raise an error for a bad configuration" do
      allow(subject).to receive(:env){ {} }
      expect { subject.load_file("spec/config/spark_api/some_random_key.yml")}.to raise_error(Errno::ENOENT)
      allow(subject).to receive(:env){ {"RAILS_ENV" => "fake_env"} }
      expect { subject.load_file(api_file)}.to raise_error(NoMethodError) 
    end
  end
  describe "oauth2" do
    let(:oauth2_file){ "spec/config/spark_api/test_oauth.yml" }
    it "should load a configured api key for development" do
      allow(subject).to receive(:env){ {} }
      expect(subject.api_env).to eq("development")
      subject.load_file(oauth2_file)
      expect(subject.oauth2?).to eq(true)
      expect(subject.authorization_uri).to eq("https://developers.sparkplatform.com/oauth2")
      expect(subject.access_uri).to eq("https://developers.sparkapi.com/v1/oauth2/grant")
      expect(subject.redirect_uri).to eq("http://localhost/oauth2/callback")
      expect(subject.client_id).to eq("developmentid124nj4qu3pua")
      expect(subject.client_secret).to eq("developmentsecret4orkp29f")
      expect(subject.endpoint).to eq("https://developers.sparkapi.com")
      expect(subject.oauth2_provider).to eq("SparkApi::TestOAuth2Provider")
      expect(subject.name).to eq("test_oauth")
      expect(subject.client_keys.keys).to match_array([:endpoint, :oauth2_provider])
      expect(subject.oauth2_keys.keys).to match_array([:authorization_uri, :client_id, :access_uri, :client_secret, :redirect_uri, :sparkbar_uri])
    end
    it "should load a configured api key for production" do
      allow(subject).to receive(:env){ {"SPARK_API_ENV" => "production"} }
      expect(subject.api_env).to eq("production")
      subject.load_file(oauth2_file)
      expect(subject.oauth2?).to eq(true)
      expect(subject.authorization_uri).to eq("https://sparkplatform.com/oauth2")
      expect(subject.access_uri).to eq("https://api.sparkapi.com/v1/oauth2/grant")
      expect(subject.redirect_uri).to eq("http://localhost/oauth2/callback")
      expect(subject.client_id).to eq("production1id124nj4qu3pua")
      expect(subject.client_secret).to eq("productionsecret4orkp29fv")
      expect(subject.endpoint).to eq("https://api.sparkapi.com")
      expect(subject.oauth2_provider).to eq(subject.class::DEFAULT_OAUTH2_PROVIDER)
      expect(subject.name).to eq("test_oauth")
    end
    
    it "should list available keys" do
      allow(SparkApi::Configuration::YamlConfig).to receive(:config_path) { "spec/config/spark_api" }
      expect(subject.class.config_keys).to match_array(["test_key", "test_oauth", "test_single_session_oauth"])
    end
  end
end
