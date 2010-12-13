
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

