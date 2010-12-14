
describe FlexmlsApi do
  describe "VERSION" do

    it "should load the version" do
      FlexmlsApi::VERSION.should match(/\d+\.\d+\.\d+/)
    end

  end

end

describe FlexmlsApi::Client do
  describe "connect" do

    it "should authenticate" do
      client = FlexmlsApi::Client.new("TopSecret", "key_of_wade", "http://api.wade.dev.fbsdata.com")
      # TODO 
    end

  end

end

describe FlexmlsApi::Authentication do
  describe "build_param_hash" do
    before(:each) do
      class StubClass
      end
      @auth_stub = StubClass.new
      @auth_stub.extend(FlexmlsApi::Authentication)
    end



    it "Should return a blank string when passed nil" do
      @auth_stub.build_param_string(nil).should be_empty
    end

    it "should return a correct param string for one item" do
      @auth_stub.build_param_string({:foo => "bar"}).should match "foobar"
    end

    it "should alphabatize the param names by key first, then by value" do
      @auth_stub.build_param_string({:zoo => "zar", :ooo => "car"}).should match "ooocarzoozar"
      @auth_stub.build_param_string({:Akey => "aValue", :aNotherkey => "AnotherValue"}).should 
           match "AkeyaValueaNotherkeyAnotherValue"
    end



  end
end
