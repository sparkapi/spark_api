require './spec/spec_helper'

describe Sort do
  before(:each) do
    stub_auth_request
  end

  it "should include the finders module" do
    Sort.should respond_to(:find)
  end

  it "should return sorts" do
    stub_api_get("/searchtemplates/sorts", 'sorts/get.json')
    sorts = Sort.find(:all)
    sorts.should be_an(Array)
    sorts.length.should eq(1)
  end

end
