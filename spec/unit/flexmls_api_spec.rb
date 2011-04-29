require './spec/spec_helper'

describe FlexmlsApi do
  after(:each) do
    reset_config
  end

  it "should load the version" do
    subject::VERSION.should match(/\d+\.\d+\.\d+/)
  end

  it "should give me a client connection" do
    subject.client.should be_a(FlexmlsApi::Client)
  end

  it "should reset my connection" do
    c1 = subject.client
    subject.reset
    subject.client.should_not eq(c1)
  end

end

