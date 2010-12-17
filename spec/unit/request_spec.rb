
describe FlexmlsApi do
  include FlexmlsApi
  describe FlexmlsApi::ClientError do
    subject { ClientError.new("1234", 200) }
    it "should have an api code" do
      subject.code.should == "1234"
    end
    it "should have an http status" do
      subject.status.should == 200
    end
    it "should raise and exception with attached message" do
      expect { raise subject, "My Message" }.to raise_error(ClientError){ |e| e.message.should == "My Message" }
    end
  end

  describe FlexmlsApi::ApiResponse do
    it "should asplode if given an invalid  or empty response" do
      expect { ApiResponse.new("KABOOOM") }.to raise_error(InvalidResponse)
      expect { ApiResponse.new({"D"=>{}}) }.to raise_error(InvalidResponse)
    end

    it "build a success response"


    it "build a failure message on error" 

  end
end
