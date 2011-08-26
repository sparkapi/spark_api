require './spec/spec_helper'


describe SharedListing do
  before(:each) do
    stub_auth_request
  end

  it "should respond to the finders" do
    SharedListing.should respond_to(:find)
  end

  it "should save shared listings" do
    stub_api_post("/#{subject.class.element_name}", 'listings/shared_listing_new.json', 'listings/shared_listing_post.json')
    subject.ListingIds = ["20110224152431857619000000","20110125122333785431000000"]
    subject.ViewId = "20080125122333787615000000"
    subject.save.should be(true)
    subject.ResourceUri.should eq("http://www.flexmls.com/share/15Ar/3544-N-Olsen-Avenue-Tucson-AZ-85719")
  end

  it "should fail saving" do
    stub_api_post("/#{subject.class.element_name}",'empty.json') do |request|
      request.to_return(:status => 400, :body => fixture('errors/failure.json'))
    end
    subject
    subject.save.should be(false)
    expect{ subject.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end
  
end
