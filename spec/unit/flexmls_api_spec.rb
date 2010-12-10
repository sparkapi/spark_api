
describe FlexmlsApi do
  describe "VERSION" do

    it "should load the version" do
      FlexmlsApi::VERSION.should match(/\d+\.\d+\.\d+/)
    end

  end

end
