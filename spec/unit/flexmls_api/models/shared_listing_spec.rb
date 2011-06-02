require './spec/spec_helper'


describe SharedListing do
  before(:each) do
    stub_auth_request
  end
  it "should save shared listings" do
    stub_api_post("/#{subject.class.element_name}", 'shared_listing_new.json', 'shared_listing_post.json')
    subject.ListingIds = ["20110224152431857619000000","20110125122333785431000000"]
    subject.ViewId = "20080125122333787615000000"
    subject.save.should be(true)
    subject.ResourceUri.should eq("http://www.flexmls.com/share/15Ar/3544-N-Olsen-Avenue-Tucson-AZ-85719")
  end

  it "should fail saving" do
    stub_request(:post, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/#{subject.class.element_name}").
      with(:query => {
        :ApiSig => "2a89896e0f20c77fd5dee326c912d973",
        :AuthToken => "c401736bf3d3f754f07c04e460e09573",
        :ApiUser => "foobar",
      },
      :body => '{"D":{}}'
      ).
      to_return(:status => 400, :body => fixture('errors/failure.json'))
    subject
    subject.save.should be(false)
    expect{ subject.save! }.to raise_error(FlexmlsApi::ClientError){ |e| e.status.should == 400 }
  end
  
end
