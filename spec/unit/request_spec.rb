
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
  
  describe FlexmlsApi::Request do
  
    context "when successfully authenticated" do
      subject do 
        class RequestTest
          include FlexmlsApi::Request
          def authenticate()
            @session = mock_session()
          end
          def sign_token(path, params = {}, post_data="")
            "SignedToken"
          end
          def version()
            "v1"
          end
          attr_accessor :connection
        end
        RequestTest.new
      end

      before(:all) do
        @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/v1/system?ApiSig=SignedToken&AuthToken=1234') { [200, {}, '{"D": {
            "Success": true, 
            "Results": [{
              "Name": "My User", 
              "OfficeId": "20070830184014994915000000", 
              "Configuration": [], 
              "Id": "20101202170654111629000000", 
              "MlsId": "20000426143505724628000000", 
              "Office": "test office", 
              "Mls": "flexmls Web Demonstration Database"
            }]}
            }'] 
          }
          stub.get('/v1/marketstatistics/price?ApiSig=SignedToken&AuthToken=1234&Options=ActiveAverageListPrice') { [200, {}, '{"D": {
            "Success": true, 
            "Results": [{
              "Dates": ["11/1/2010","10/1/2010","9/1/2010","8/1/2010","7/1/2010",
                                 "6/1/2010","5/1/2010","4/1/2010","3/1/2010","2/1/2010",
                                 "1/1/2010","12/1/2009"], 
              "ActiveAverageListPrice": [100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000]
            }]}
            }'] 
          }
          stub.post('/v1/contacts?ApiSig=SignedToken&AuthToken=1234') { [200, {}, '{"D": {
            "Success": true, 
            "Results": [{}]}}'] 
          }
        end
        @connection = Faraday::Connection.new() do |builder|
          builder.adapter :test, @stubs
          builder.use Faraday::Response::ParseJson
          builder.use FlexmlsApi::FaradayExt::ApiErrors
        end
        subject.connection = @connection 
      end  
      
      it "should get a service" do
        subject.get('/system')[0]["Name"].should == "My User"
      end

      it "should get a service with parameters" do
        subject.get('/marketstatistics/price', "Options" => "ActiveAverageListPrice")[0]["ActiveAverageListPrice"].should == [100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000]
      end
      

      it "should post to a service"

      it "should put to a service"

      it "should delete from a service"
      
    end
    
  end
  
end
