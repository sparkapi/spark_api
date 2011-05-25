require './spec/spec_helper'

# Test client implemenations for multi client switching
module FlexmlsApi
  def self.test_client_a
    Client.new(:api_key => "a")
  end
  def self.test_client_b
    Client.new(:api_key => "b")
  end
  def self.test_client_c
    Client.new(:api_key => "c")
  end
end

describe FlexmlsApi::MultiClient do
  it "should activate a client implemenation when activate()" do
    FlexmlsApi.activate(:test_client_a)
    FlexmlsApi.client.api_key.should eq('a')
    FlexmlsApi.activate(:test_client_b)
    FlexmlsApi.client.api_key.should eq('b')
    FlexmlsApi.activate(:test_client_c)
    FlexmlsApi.client.api_key.should eq('c')
    FlexmlsApi.activate(:test_client_a)
    FlexmlsApi.client.api_key.should eq('a')
  end
  it "should fail to activate symbols that do not have implementations" do
    expect { FlexmlsApi.activate(:test_client_d) }.to raise_error(ArgumentError)
  end
  
  it "should temporarily activate a client implemenation when activate() block" do
    FlexmlsApi.activate(:test_client_a)
    FlexmlsApi.client.api_key.should eq('a')
    FlexmlsApi.activate(:test_client_b) do
      FlexmlsApi.client.api_key.should eq('b')
    end
    FlexmlsApi.client.api_key.should eq('a')
    expect do
      FlexmlsApi.activate(:test_client_c) do
        FlexmlsApi.client.api_key.should eq('c')
        raise "OH MY GOODNESS I BLEW UP!!!"
      end
    end.to raise_error
    FlexmlsApi.client.api_key.should eq('a')
  end
  
end

