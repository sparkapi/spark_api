require './spec/spec_helper'

describe Photo do
  describe "find" do
    subject do
      Photo.new({
        "ResourceUri" => "/listings/20100815153524571646000000/photos/20101124153422574618000000",
        "Id"          => "20101124153422574618000000",
        "Name"        => "Photo 1 name",
        "Caption"     => "caption here",
        "UriThumb"    => "http://photos.cdn.flexmls.com/xyz-t.jpg",
        "Uri300"      => "http://photos.cdn.flexmls.com/xyz.jpg",
        "Uri640"      => "http://cdn.resize.flexmls.com/az/640x480/true/20101124153422574618000000-o.jpg",
        "Uri800"      => "http://cdn.resize.flexmls.com/az/800x600/true/20101124153422574618000000-o.jpg",
        "Uri1024"     => "http://cdn.resize.flexmls.com/az/1024x768/true/20101124153422574618000000-o.jpg",
        "Uri1280"     => "http://cdn.resize.flexmls.com/az/1280x1024/true/20101124153422574618000000-o.jpg",
        "UriLarge"    => "http://photos.cdn.flexmls.com/xyz-o.jpg",
        "Primary"     => true
      })
    end

    it "responds to" do
      subject.should respond_to(:primary?)
      Photo.should respond_to(:find_by_listing_key)
    end

    it "knows if it's the primary photo" do
      subject.primary?.should be_true
      subject.Primary = false
      subject.primary?.should be_false
    end
  end

  describe "URIs" do
    subject do
      p = Photo.build_subclass.tap do |photo|
        photo.prefix = "/listings/1234"
        photo.element_name ="/photos"
      end.new
      p.update_path = "/listings/1234/photos"
      p
    end

    it "should be scoped to a listing" do
      subject.class.path.should eq("/listings/1234/photos")
    end

    describe "/listings/<listing_id>/photos", :support  do
      before(:each) do
        stub_auth_request
        stub_api_get('/listings/1234/photos', 'listings/photos/index.json')
      end

      on_get_it "should get an array of photos" do
        p = Photo.find_by_listing_key('1234')
        p.should be_an(Array)
      end

      on_post_it "should upload a new photo" do
        stub_api_post('/listings/1234/photos', 'listings/photos/new.json', 'listings/photos/post.json')
        subject.Name  = "FBS Logo"
        subject.Caption = "Creators of flexMLS!"
        subject.load_picture("spec/fixtures/logo_fbs.png")
        subject.save!
        subject.Id.should eq("20110826220032167405000000")
      end
    end

    describe "/listings/<listing_id>/photos/<photo_id>", :support do
      before(:each) do
        stub_auth_request
      end

      on_put_it "should upload a modified photo" do
        stub_api_put('/listings/1234/photos/20110826220032167405000000', 'listings/photos/new.json', 'listings/photos/post.json')
        subject.Id = "20110826220032167405000000"
        subject.Name  = "FBS Logo"
        subject.Caption = "Creators of flexMLS!"
        subject.load_picture("spec/fixtures/logo_fbs.png")
        subject.save!
        subject.Id.should eq("20110826220032167405000000")
      end

      on_delete_it "should delete a photo" do
        stub_api_delete('/listings/1234/photos/20110826220032167405000000','success.json')
        subject.Id = "20110826220032167405000000"
        subject.delete
      end
    end
  end

end
