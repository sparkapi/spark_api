require 'spec_helper'

describe SparkApi::Request::Parallel do

  before(:each) do
    stub_auth_request
    client.authenticate
  end

  subject(:client) { SparkApi.client }

  it "makes some requests in parallel" do
    stub_api_get "/testplace1", "success.json"
    stub_api_get "/testplace2", "success.json"
    stub_api_get "/testplace3", "success.json"
    client.in_parallel do
      client.get "/testplace1"
      client.get "/testplace2"
      client.get "/testplace3"
    end
  end

  it "doesn't raise exceptions for failed requests" do
    stub_api_get "/a_place1", "success.json", { :status => 404 }
    stub_api_get "/a_place2", "success.json", { :status => 404 }

    # normal request should raise exception
    expect do
      client.get "/a_place1"
    end.to raise_error SparkApi::NotFound

    # request in parallel shouldn't, but we can check the response afterward instead
    response = nil
    expect do
      client.in_parallel do
        response = client.get "/a_place2"
      end
    end.not_to raise_error
    response.status.should eq(404)
  end

  it "returns all of the responses" do
    stub_api_get "/testplace1", "success.json"
    stub_api_get "/testplace2", "success.json"
    stub_api_get "/testplace3", "success.json"
    responses = client.in_parallel do
      client.get "/testplace1"
      client.get "/testplace2"
      client.get "/testplace3"
    end
    responses.size.should eq(3)
    responses.first.should be_a(Faraday::Response)
  end

end
