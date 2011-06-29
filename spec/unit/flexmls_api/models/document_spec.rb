require './spec/spec_helper'

describe Document do
  before(:each) do
    @document = Document.new({
      :Uri => "http://images.dev.fbsdata.com/documents/cda/20060725224801143085000000.pdf",
      :ResourceUri => "/v1/listings/20060725224713296297000000/documents/20060725224801143085000000",
      :Name => "Disclosure",
      :Id => "20110105165843978012000000",
    })
  end

  it "should respond to a few methods" do
    Document.should respond_to(:find_by_listing_key)
  end

  it "should get documents for a listing" do
    stub_auth_request
    stub_api_get('/listings/1234/documents','listing_document_index.json')

    v = Document.find_by_listing_key('1234')
    v.should be_an(Array)
    v.length.should == 2
  end

  after(:each) do
    @document = nil
  end

end
