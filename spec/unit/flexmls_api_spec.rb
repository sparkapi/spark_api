
describe FlexmlsApi do
  describe "VERSION" do

    it "should load the version" do
      FlexmlsApi::VERSION.should match(/\d+\.\d+\.\d+/)
    end

  end

end

describe FlexmlsApi::Client do
  describe "default settings" do
    it "should return the proper defaults when called with no arguments" do
      FlexmlsApi.api_key.should be_nil
      FlexmlsApi.api_secret.should be_nil
      FlexmlsApi.version.should match "v1"
      FlexmlsApi.endpoint.should match "api.flexmls.com"

      FlexmlsApi.api_key = "my_api_key"
      FlexmlsApi.api_key.should match "my_api_key"
    end
  end

  describe "configure" do

    it "should return a properly configured client" do
      client = FlexmlsApi::Client.new(:api_key => "key_of_wade", 
                                      :api_secret => "TopSecret", 
                                      :endpoint => "http://api.wade.dev.fbsdata.com")
 
      client.api_key.should match "key_of_wade"
      client.api_secret.should match "TopSecret"
      client.endpoint.should match "http://api.wade.dev.fbsdata.com"
      client.version.should match "v1"
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

