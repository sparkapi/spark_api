require './spec/spec_helper'

describe SparkApi do

  it "should use 'yajl-ruby' for parsing json" do
    expect(MultiJson.engine).to eq(MultiJson::Adapters::Yajl) unless jruby?
  end

  it "should load the version" do
    expect(subject::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  it "should give me a client connection" do
    expect(subject.client).to be_a(SparkApi::Client)
  end

  it "should reset my connection" do
    c1 = subject.client
    subject.reset
    expect(subject.client).not_to eq(c1)
  end

  it "should let me override the default logger" do
    expect(subject.logger.level).to eq(Logger::DEBUG) # default overridden in spec_helper

    subject.logger = Logger.new('/dev/null')
    subject.logger.level = Logger::WARN

    expect(SparkApi.logger.level).to eq(Logger::WARN)
  end
end

