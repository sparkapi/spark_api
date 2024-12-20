require './spec/spec_helper'

# Test client implemenations for multi client switching
module SparkApi
  def self.test_client_a
    Thread.current[:test_client_a] ||= Client.new(:api_key => "a")
  end
  def self.test_client_b
    Client.new(:api_key => "b")
  end
  def self.test_client_c
    Client.new(:api_key => "c")
  end
end

describe SparkApi::MultiClient do

  before(:all) { SparkApi.reset }
  after(:all) { SparkApi.reset }

  it "should activate a client implemenation when activate()" do
    SparkApi.activate(:test_client_a)
    expect(SparkApi.client.api_key).to eq('a')
    SparkApi.activate(:test_client_b)
    expect(SparkApi.client.api_key).to eq('b')
    SparkApi.activate(:test_client_c)
    expect(SparkApi.client.api_key).to eq('c')
    SparkApi.activate(:test_client_a)
    expect(SparkApi.client.api_key).to eq('a')
  end
  it "should fail to activate symbols that do not have implementations" do
    expect { SparkApi.activate(:test_client_d) }.to raise_error(ArgumentError)
  end
  
  it "should temporarily activate a client implemenation when activate() block" do
    SparkApi.activate(:test_client_a)
    expect(SparkApi.client.api_key).to eq('a')
    SparkApi.activate(:test_client_b) do
      expect(SparkApi.client.api_key).to eq('b')
    end
    expect(SparkApi.client.api_key).to eq('a')
    expect do
      SparkApi.activate(:test_client_c) do
        expect(SparkApi.client.api_key).to eq('c')
        raise "OH MY GOODNESS I BLEW UP!!!"
      end
    end.to raise_error(RuntimeError)
    expect(SparkApi.client.api_key).to eq('a')
  end

  context "yaml" do
    before :each do
      allow(SparkApi::Configuration::YamlConfig).to receive(:config_path) { "spec/config/spark_api" }
    end

    it "should activate a client implemenation when activate()" do
      SparkApi.activate(:test_key)
      expect(SparkApi.client.api_key).to eq('demo_key')
    end

    it "should activate a single session key" do
      allow(SparkApi::Configuration::YamlConfig).to receive(:config_path) { "spec/config/spark_api" }
      SparkApi.activate(:test_single_session_oauth)
      expect(SparkApi.client.session).to respond_to(:access_token)
      expect(SparkApi.client.session.access_token).to eq("yay success!")
    end
  end
  
end

