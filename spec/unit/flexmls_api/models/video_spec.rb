require './spec/spec_helper'

describe FlexmlsApi::Models::Video do


  it "responds to" do
    FlexmlsApi::Models::Video.should respond_to(:find_by_listing_key)
    FlexmlsApi::Models::Video.new.should respond_to(:branded?)
    FlexmlsApi::Models::Video.new.should respond_to(:unbranded?)
  end

  it "has a type" do
    FlexmlsApi::Models::Video.new(:Type => "branded").branded?.should == true
    FlexmlsApi::Models::Video.new(:Type => "unbranded").branded?.should == false
    FlexmlsApi::Models::Video.new(:Type => "unbranded").unbranded?.should == true
    FlexmlsApi::Models::Video.new(:Type => "branded").unbranded?.should == false
  end


  describe "find videos by listing id"  do
    before do
      stub_auth_request
      stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}/listings/1234/videos").
                   with(:query => {
                     :ApiSig => "c95bfef766128b91a2643fcc2fa40dfc", 
                     :AuthToken => "c401736bf3d3f754f07c04e460e09573",
                     :ApiUser => "foobar"
                   }).
                   to_return(:body => fixture('listing_videos_index.json'))
    end

    it "should get an array of videos" do
      p = FlexmlsApi::Models::Video.find_by_listing_key('1234', 'foobar')
      p.should be_an Array
      p.length.should == 2
    end

  end




end
