# Test out the faraday connection stack.
describe FlexmlsApi do
  include FlexmlsApi
  describe "ApiErrors" do
    before(:all) do
      @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/session') { [200, {}, '{"D": { 
            "Success": true,
            "Results": [{
                "AuthToken": "xxxxx",
                "Expires": "2010-10-30T15:49:01-05:00",
                "Roles": ["idx"] 
                }]
          }}'] 
        }
        stub.post('/system') { [200, {}, '{"D": {
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
        stub.get('/expired') { [401, {}, '{"D": { 
            "Success": false,
            "Message": "Session token has expired",
            "Code": "1020"            
          }}'] 
        }
        stub.get('/methodnotallowed') { [405, {}, '{"D": { 
            "Success": false,
            "Message": "Method Not Allowed",
            "Code": "1234"            
          }}'] 
        }
        stub.get('/invalidjson') { [200, {}, '{"OMG": "THIS IS NOT THE API JSON THAT I KNOW AND <3!!!"}'] }
        stub.get('/garbage') { [200, {}, 'THIS IS TOTAL GARBAGE!'] }
      end

      @connection = Faraday::Connection.new() do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::ParseJson
        builder.use FlexmlsApi::FaradayExt::ApiErrors
      end

    end
    
    it "should should raised exception when token is expired" do
      expect { @connection.get('/expired')}.to raise_error(PermissionDenied){ |e| e.code.should == ResponseCodes::SESSION_TOKEN_EXPIRED }
    end

    it "should should raised exception on error" do
      expect { @connection.get('/methodnotallowed')}.to raise_error(NotAllowed){ |e| e.message.should == "Method Not Allowed" }
    end

    it "should should raised exception on invalid responses" do
      expect { @connection.get('/invalidjson')}.to raise_error(InvalidResponse)
      # This should be caught in the request code
      expect { @connection.get('/garbage')}.to raise_error(MultiJson::DecodeError)
    end

    it "should give me a session response" do
      response = @connection.post('/session').body
      response.success.should eq(true)
      session = FlexmlsApi::Authentication::Session.new(response.results[0])
      session.auth_token.should eq("xxxxx")
    end
    
    it "should give me an api response" do
      response = @connection.post('/system').body
      response.success.should eq(true)
      response.results.length.should be > 0 
    end
    
  end
  
end

