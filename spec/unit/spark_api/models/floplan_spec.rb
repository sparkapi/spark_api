require './spec/spec_helper'

describe FloPlan do

  it "responds to" do
    expect(FloPlan).to respond_to(:find_by_listing_key)
  end

  describe "/listings/<listing_id>/videos", :support do
    before do
      stub_auth_request
      stub_api_get('/listings/1234/floplans','listings/floplans_index.json')
    end

    on_get_it "should correctly split images and thumbnails" do
      p = FloPlan.find_by_listing_key('1234').first
      expect(p.attributes['Images'].length).to eq 2
      expect(p.images.length).to eq 1
      expect(p.thumbnails.length).to eq 1
    end

  end

end
