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
    before :each do
      SparkApi::Configuration::YamlConfig.stub(:config_path) { "spec/config/spark_api" }
    end

    it "should activate a client implemenation when activate()" do
      SparkApi.activate(:test_key)
      SparkApi.client.api_key.should eq('demo_key')
    end

    it "should activate a single session key" do
      SparkApi::Configuration::YamlConfig.stub(:config_path) { "spec/config/spark_api" }
      SparkApi.activate(:test_single_session_oauth)
      SparkApi.client.session.should respond_to(:access_token)
      SparkApi.client.session.access_token.should eq("yay success!")
    end
  end
  
end

