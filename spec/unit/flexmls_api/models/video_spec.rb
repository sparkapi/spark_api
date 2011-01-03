require './spec/spec_helper'

describe FlexmlsApi::Models::Video do


  it "responds to" do
    FlexmlsApi::Models::Video.should respond_to(:find_by_listing_key)
  end


  describe "find videos by listing id"  do
    before do
      stub_auth_request
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234/videos").
                   with(:query => {:ApiSig => "86f507079e2ba1c6840f9c86d5b1f0e8", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}).
                   to_return(:body => fixture('listing_videos_index.json'))
    end

    it "should get an array of videos" do
      p = FlexmlsApi::Models::Video.find_by_listing_key('1234')
      p.should be_an Array
      p.length.should == 2
    end

  end




end
