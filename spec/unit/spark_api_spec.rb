require './spec/spec_helper'

describe SparkApi do

  it "should use 'oj' for parsing json" do
    MultiJson.engine.should eq(MultiJson::Adapters::Oj) unless jruby?
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

  it "should let me override the default logger" do
    subject.logger.level.should eq(Logger::DEBUG) # default overridden in spec_helper

    subject.logger = Logger.new('/dev/null')
    subject.logger.level = Logger::WARN

    SparkApi.logger.level.should eq(Logger::WARN)
  end
end

