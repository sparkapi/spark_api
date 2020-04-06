require './spec/spec_helper'

describe FloPlan do

  it "responds to" do
    FloPlan.should respond_to(:find_by_listing_key)
  end

  describe "/listings/<listing_id>/videos", :support do
    before do
      stub_auth_request
      stub_api_get('/listings/1234/floplans','listings/floplans_index.json')
    end

    on_get_it "should correctly split images and thumbnails" do
      p = FloPlan.find_by_listing_key('1234').first
      p.attributes['Images'].length.should == 2
      p.images.length.should == 1
      p.thumbnails.length.should == 1
    end

  end

end
