
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

    it "should have results when successful" do
      r = ApiResponse.new({"D"=>{"Success" => true, "Results" => []}})
      r.success?.should be true
      r.results.empty?.should be true
    end

    it "should have a message on error" do
      r = ApiResponse.new({"D"=>{"Success" => false, "Message" => "I am a failure."}})
      r.success?.should be false
      r.message.should be == "I am a failure."
    end

  end

  
end
