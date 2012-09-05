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
  it "should activate a client implemenation when activate()" do
    SparkApi.activate(:test_client_a)
    SparkApi.client.api_key.should eq('a')
    SparkApi.activate(:test_client_b)
    SparkApi.client.api_key.should eq('b')
    SparkApi.activate(:test_client_c)
    SparkApi.client.api_key.should eq('c')
    SparkApi.activate(:test_client_a)
    SparkApi.client.api_key.should eq('a')
  end
  it "should fail to activate symbols that do not have implementations" do
    expect { SparkApi.activate(:test_client_d) }.to raise_error(ArgumentError)
  end
  
  it "should temporarily activate a client implemenation when activate() block" do
    SparkApi.activate(:test_client_a)
    SparkApi.client.api_key.should eq('a')
    SparkApi.activate(:test_client_b) do
      SparkApi.client.api_key.should eq('b')
    end
    SparkApi.client.api_key.should eq('a')
    expect do
      SparkApi.activate(:test_client_c) do
        SparkApi.client.api_key.should eq('c')
        raise "OH MY GOODNESS I BLEW UP!!!"
      end
    end.to raise_error
    SparkApi.client.api_key.should eq('a')
  end

  context "yaml" do
    it "should activate a client implemenation when activate()" do
      SparkApi::Configuration::YamlConfig.stub(:config_path) { "spec/config/spark_api" }
      SparkApi.activate(:test_key)
      SparkApi.client.api_key.should eq('demo_key')
    end
  end

  after(:all) do
    reset_config
  end
  
end

