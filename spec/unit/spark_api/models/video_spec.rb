require './spec/spec_helper'

describe Video do

  it "responds to" do
    expect(Video).to respond_to(:find_by_listing_key)
    expect(Video.new).to respond_to(:branded?)
    expect(Video.new).to respond_to(:unbranded?)
  end

  it "has a type" do
    expect(Video.new(:Type => "branded").branded?).to eq(true)
    expect(Video.new(:Type => "unbranded").branded?).to eq(false)
    expect(Video.new(:Type => "unbranded").unbranded?).to eq(true)
    expect(Video.new(:Type => "branded").unbranded?).to eq(false)
  end

  describe "/listings/<listing_id>/videos", :support do
    before do
      stub_auth_request
      stub_api_get('/listings/1234/videos','listings/videos_index.json')
    end

    on_get_it "should get an array of videos" do
      p = Video.find_by_listing_key('1234')
      expect(p).to be_an(Array)
      expect(p.length).to eq(2)
    end

  end

  context "/listings/<listing_id>/videos/<video_id>", :support do
    on_get_it "should return information about a single video"
  end

end
