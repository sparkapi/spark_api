require './spec/spec_helper'
require 'zlib'

# Test out the faraday connection stack.
describe SparkApi do
  describe "SparkMiddleware" do
    before(:all) do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/session') { [200, {}, '{"D": { 
            "Success": true,
            "Results": [{
                "AuthToken": "xxxxx",
                "Expires": "2010-10-30T15:49:01-05:00",
                "Roles": ["idx"] 
                }]
          }}'] 
        }
        stub.get('/system') { [200, {}, '{"D": {
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
        stub.get('/expired') { [401, {}, fixture('errors/expired.json')] 
        }
        stub.get('/methodnotallowed') { [405, {}, '{"D": { 
            "Success": false,
            "Message": "Method Not Allowed",
            "Code": "1234"            
          }}'] 
        }
        stub.get('/epicfail') { [500, {}, '{"D": { 
            "Success": false,
            "Message": "EPIC FAIL",
            "Code": "0000"            
          }}'] 
        }
        stub.get('/unknownerror') { [499, {}, '{"D": { 
            "Success": false,
            "Message": "Some random status error",
            "Code": "0000"
          }}'] 
        }
        stub.get('/badresourcerequest') { [409, {}, '{"D": {
            "Message": "FlexmlsApiResponse::Errors::Errors", 
            "Code": 1053, 
            "Success": false, 
            "Errors": "Some errors and stuff."
          }}'] 
        }
        stub.get('/invalidjson') { [200, {}, '{"OMG": "THIS IS NOT THE API JSON THAT I KNOW AND <3!!!"}'] }
        stub.get('/garbage') { [200, {}, 'THIS IS TOTAL GARBAGE!'] }
      end

      @connection = test_connection(stubs)

    end
    
    it "should raised exception when token is expired" do
      expect { @connection.get('/expired')}.to raise_error(SparkApi::PermissionDenied){ |e| expect(e.code).to eq(SparkApi::ResponseCodes::SESSION_TOKEN_EXPIRED) }
    end

    it "should raised exception on error" do
      expect { @connection.get('/methodnotallowed')}.to raise_error(SparkApi::NotAllowed){ |e| expect(e.message).to eq("Method Not Allowed") }
      expect { @connection.get('/epicfail')}.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to be(500) }
      expect { @connection.get('/unknownerror')}.to raise_error(SparkApi::ClientError){ |e| expect(e.status).to be(499) }
    end

    it "should raised exception on invalid responses" do
      expect { @connection.get('/invalidjson')}.to raise_error(SparkApi::InvalidResponse)
      # This should be caught in the request code
      expect { @connection.get('/garbage')}.to raise_error(SparkApi::InvalidJSON)
    end

    it "should give me a session response" do
      response = @connection.post('/session').body
      expect(response.success).to eq(true)
      session = SparkApi::Authentication::Session.new(response.results[0])
      expect(session.auth_token).to eq("xxxxx")
    end
    
    it "should give me an api response" do
      response = @connection.get('/system').body
      expect(response.success).to eq(true)
      expect(response.results.length).to be > 0 
    end

    it "should include the errors in the response" do
      expect { @connection.get('/badresourcerequest')}.to raise_error(SparkApi::BadResourceRequest){ |e| 
        expect(e.errors).to eq("Some errors and stuff.")
      }
    end

  end

  describe "#decompress_body" do
    let(:middleware) do
      SparkApi::FaradayMiddleware.new(SparkApi)
    end

    it "should leave the body along if content-encoding not set" do
      env = {
        :body => "UNCOMPRESSED",
        :response_headers => {}
      }

      expect(middleware.decompress_body(env)).to eq("UNCOMPRESSED")
    end

    it "should unzip gzipped data" do
      bod = "OUTPUT BODY"

      out = StringIO.new
      gz = Zlib::GzipWriter.new(out)
      gz.write bod
      gz.close

      env = {
        :body => out.string,
        :response_headers => {
          'content-encoding' => 'gzip'
        }
      }

      expect(middleware.decompress_body(env)).to eq(bod)
    end

    it "should inflate deflated data" do
      bod = "INFLATED BODY"
      deflated_bod = Zlib::Deflate.deflate(bod)

      env = {
        :body => deflated_bod,
        :response_headers => {
          'content-encoding' => 'deflate'
        }
      }

      expect(middleware.decompress_body(env)).to eq(bod)
    end
  end
  
end

