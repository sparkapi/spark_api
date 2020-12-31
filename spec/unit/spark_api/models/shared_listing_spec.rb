require './spec/spec_helper'


describe SharedListing do
  before(:each) do
    stub_auth_request
  end

  it "should respond to the finders" do
    expect(SharedListing).to respond_to(:find)
  end

  context "/sharedlistings", :support do
    on_post_it "should create shared listings" do
      stub_api_post("/#{subject.class.element_name}", 'listings/shared_listing_new.json', 'listings/shared_listing_post.json')
      subject.ListingIds = ["20110224152431857619000000","20110125122333785431000000"]
      subject.ViewId = "20080125122333787615000000"
      expect(subject.save).to be(true)
      expect(subject.Id).to eq("15Ar")
      expect(subject.Mode).to eq("Public")
      expect(subject.ResourceUri).to eq("/v1/sharedlistings/15Ar")
      expect(subject.SharedUri).to eq("http://www.flexmls.com/share/15Ar/3544-N-Olsen-Avenue-Tucson-AZ-85719")
    end

    on_post_it "should fail creating" do
      stub_api_post("/#{subject.class.element_name}", nil) do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end
      subject
      expect(subject.save).to be(false)
      expect{ subject.save! }.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to eq(400) }
    end
  end

  context "/sharedlistings/<shared_listing_id>", :support do
    on_get_it "should get shared listing" do
      shared_id = '15Ar'
      stub_api_get("/#{subject.class.element_name}/#{shared_id}",
                   'listings/shared_listing_get.json')

      shared = SharedListing.find(shared_id)
      expect(shared).to respond_to('SharedUri')
      expect(shared).to respond_to('Mode')
      expect(shared.Mode).to eq('Public')
      expect(shared.ListingIds).to be_an(Array)
    end
  end

end
