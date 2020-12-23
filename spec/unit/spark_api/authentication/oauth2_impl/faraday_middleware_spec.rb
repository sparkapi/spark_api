require 'spec_helper'
require 'support/oauth2_helper'

describe SparkApi::Authentication::OAuth2Impl::SparkbarFaradayMiddleware do
  subject { SparkApi::Authentication::OAuth2Impl::SparkbarFaradayMiddleware.new("test") }
  # Make sure the client boostraps the right plugin based on configuration.
  it "should parse token on successful response" do
    env = {
      :body => '{"token":"sp4rkb4rt0k3n"}',
      :status => 201
    }
    subject.on_complete env
    expect(env[:body]["token"]).to eq("sp4rkb4rt0k3n")
  end
  
  it "should raise error on unsuccessful response" do
    env = {
      :body => '{"token":"sp4rkb4rt0k3n"}',
      :status => 500
    }
    expect {subject.on_complete env }.to raise_error(SparkApi::ClientError)
  end

  it "should raise error on invalid json" do
    env = {
      :body => '{"BORKBORKBORK"}',
      :status => 200
    }
    expect {subject.on_complete env }.to raise_error(MultiJson::DecodeError)
  end
  
end
