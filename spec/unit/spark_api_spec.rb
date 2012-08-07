require './spec/spec_helper'

describe SparkApi do
  after(:each) do
    reset_config
  end

  it "should use 'yajl-ruby' for parsing json" do
    MultiJson.engine.should eq(MultiJson::Adapters::Yajl)
  end

  it "should load the version" do
    subject::VERSION.should match(/\d+\.\d+\.\d+/)
  end

  it "should give me a client connection" do
    subject.client.should be_a(SparkApi::Client)
  end

  it "should reset my connection" do
    c1 = subject.client
    subject.reset
    subject.client.should_not eq(c1)
  end

end

