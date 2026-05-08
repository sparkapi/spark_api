require './spec/spec_helper'

describe SparkApi::ResoFaradayMiddleware do
  def reso_test_connection(stubs)
    Faraday.new(nil, headers: SparkApi::Client.new.headers) do |conn|
      conn.response :reso_api
      conn.adapter :test, stubs
    end
  end

  let(:xml_metadata) do
    %(<?xml version="1.0" encoding="UTF-8"?>\n<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx"/>\n)
  end

  let(:json_d_envelope) do
    '{"D":{"Success":true,"Results":[{"Name":"My User"}]}}'
  end

  let(:plain_json_no_d) do
    '{"@odata.context":"https://api.example.com/$metadata#Property","value":[]}'
  end

  let(:non_json_non_xml_garbage) do
    'TOTAL GARBAGE'
  end

  it "passes JSON bodies wrapped in the legacy +D+ envelope through to the parent middleware" do
    stubs = Faraday::Adapter::Test::Stubs.new { |s| s.get('/v1/system') { [200, {}, json_d_envelope] } }
    response = reso_test_connection(stubs).get('/v1/system')
    expect(response.body.success).to eq(true)
    expect(response.body.results.first['Name']).to eq('My User')
  end

  it "decodes a flat OData JSON response (no +D+ envelope) and stores it on +env[:body]+" do
    stubs = Faraday::Adapter::Test::Stubs.new { |s| s.get('/Property') { [200, {}, plain_json_no_d] } }
    response = reso_test_connection(stubs).get('/Property')
    expect(response.body).to be_a(Hash)
    expect(response.body['@odata.context']).to eq('https://api.example.com/$metadata#Property')
  end

  # Regression: prior to this fix the JSON parse-error rescue referenced the
  # local +body+ variable, but the +MultiJson.decode+ call in the +begin+
  # block had already raised before +body+ was assigned, so it was always
  # nil at the rescue point. Calling +.strip+ on nil raised
  # +NoMethodError: undefined method `strip' for nil:NilClass+ for *every*
  # XML response, including the +/$metadata+ endpoint.
  it "passes a RESO XML metadata body through without raising NoMethodError" do
    stubs = Faraday::Adapter::Test::Stubs.new do |s|
      s.get('/$metadata') { [200, { 'Content-Type' => 'application/xml' }, xml_metadata] }
    end
    expect {
      response = reso_test_connection(stubs).get('/$metadata')
      expect(response.body).to eq(xml_metadata)
    }.not_to raise_error
  end

  it "raises the original MultiJson::ParseError for non-JSON, non-XML bodies" do
    stubs = Faraday::Adapter::Test::Stubs.new do |s|
      s.get('/garbage') { [200, {}, non_json_non_xml_garbage] }
    end
    expect { reso_test_connection(stubs).get('/garbage') }.to raise_error(MultiJson::ParseError)
  end
end
