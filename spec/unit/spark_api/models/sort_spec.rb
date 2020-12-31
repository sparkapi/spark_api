require './spec/spec_helper'

describe Sort do
  before(:each) do
    stub_auth_request
  end

  it "should include the finders module" do
    expect(Sort).to respond_to(:find)
  end

  it "should return sorts" do
    stub_api_get("/searchtemplates/sorts", 'sorts/get.json')
    sorts = Sort.find(:all)
    expect(sorts).to be_an(Array)
    expect(sorts.length).to eq(1)
  end

end
