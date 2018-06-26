require './spec/spec_helper'

describe SparkApi do
  describe SparkApi::ClientError do
    subject { SparkApi::ClientError.new({:message=>"OMG FAIL", :code=>1234, :status=>500, :request_path => '/v1/foo', :request_id => 'deadbeef'}) }
    it "should print a helpful to_s" do
      subject.to_s.should == "OMG FAIL"
      subject.message.should == "OMG FAIL"
    end
    it "should have an api code" do
      subject.code.should == 1234
    end
    it "should have an http status" do
      subject.status.should == 500
    end

    it "should have a request_path" do
      subject.request_path.should == '/v1/foo'
    end

    it "should have a request_id" do
      subject.request_id.should == 'deadbeef'
    end

    it "should raise and exception with attached message" do
      expect { raise subject.class, {:message=>"My Message", :code=>1000, :status=>404}}.to raise_error(SparkApi::ClientError)  do |e| 
        e.message.should == "My Message" 
        e.code.should == 1000
        e.status.should == 404
      end
      expect { raise subject.class.new({:message=>"My Message", :code=>1000, :status=>404}) }.to raise_error(SparkApi::ClientError)  do |e| 
        e.message.should == "My Message" 
        e.code.should == 1000
        e.status.should == 404
      end
      expect { raise subject.class.new({:code=>1000, :status=>404}), "My Message"}.to raise_error(SparkApi::ClientError)  do |e| 
        e.message.should == "My Message" 
        e.code.should == 1000
        e.status.should == 404
      end
      expect { raise subject.class, "My Message"}.to raise_error(SparkApi::ClientError)  do |e| 
        e.message.should == "My Message" 
        e.code.should be == nil
        e.status.should be == nil
        e.request_id.should be == nil
      end
    end
  end

  describe SparkApi::ApiResponse do
    it "should asplode if given an invalid  or empty response" do
      expect { SparkApi::ApiResponse.new("KABOOOM") }.to raise_error(SparkApi::InvalidResponse)
      expect { SparkApi::ApiResponse.new({"D"=>{}}) }.to raise_error(SparkApi::InvalidResponse)
    end
    it "should have results when successful" do
      r = SparkApi::ApiResponse.new({"D"=>{"Success" => true, "Results" => []}})
      r.success?.should be(true)
      r.results.empty?.should be(true)
      r.request_id.should eq nil
    end

    it "should return the request_id" do
      r = SparkApi::ApiResponse.new({"D"=>{"Success" => true, "Results" => []}}, 'foobar')
      r.success?.should be(true)
      r.request_id.should eq('foobar')
    end
    it "should have a message on error" do
      r = SparkApi::ApiResponse.new({"D"=>{"Success" => false, "Message" => "I am a failure."}})
      r.success?.should be(false)
      r.message.should be == "I am a failure."
    end
    it "should have SparkQLErrors when present" do
      err = {"Token" => "ExpirationDate", "Status" => "Dropped"}
      r = SparkApi::ApiResponse.new({"D"=>{"Success" => false, "Message" => "I am a failure from .",
        "SparkQLErrors" => [err]
      }})
      r.sparkql_errors.first.should eq(err)
    end
    it "should have Errors when present" do
      err = {"Type" => "InvalidAttribute", "Attribute" => "DisplayName", "Message" => "DisplayName is wrong."}
      r = SparkApi::ApiResponse.new({"D"=>{"Success" => false, "Message" => "I am a failure from .",
        "Errors" => [err]
      }})
      r.errors.first.should eq(err)
    end
  end
  
  describe SparkApi::Request do
    before(:all) do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
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
        stub.post('/v1/contacts?ApiSig=SignedToken&AuthToken=1234', '{"D":{"Contacts":[{"DisplayName":"Wades Contact","PrimaryEmail":"wade11@fbsdata.com"}]}}') { [201, {}, '{"D": {
          "Success": true,
          "Results": [{"ResourceUri": "1000"}]}}'] 
        }
        stub.put('/v1/contacts/1000?ApiSig=SignedToken&AuthToken=1234', '{"D":{"Contacts":[{"DisplayName":"WLMCEWENS Contact","PrimaryEmail":"wlmcewen789@fbsdata.com"}]}}') { [200, {}, '{"D": {
          "Success": true}}'] 
        }
        stub.delete('/v1/contacts/1000?ApiSig=SignedToken&AuthToken=1234') { [200, {}, '{"D": {
          "Success": true}}'] 
        }
        # Other MISC requests
        stub.post('/v1/stringdata?ApiSig=SignedToken&AuthToken=1234', 'I am a lonely String!') { [200, {}, '{"D": {
          "Success": true,
          "Results": []}}'] 
        }
        # EXPIRED RESPONSES
        stub.get('/v1/system?ApiSig=SignedToken&AuthToken=EXPIRED') { [401 , {}, '{"D": {
          "Success": false,
          "Message": "Session token has expired",
          "Code": 1020
          }}'] 
        }
        stub.post('/v1/contacts?ApiSig=SignedToken&AuthToken=EXPIRED', '{"D":{"Contacts":[{"DisplayName":"Wades Contact","PrimaryEmail":"wade11@fbsdata.com"}]}}') { [401 , {}, '{"D": {
          "Success": false,
          "Message": "Session token has expired",
          "Code": 1020
          }}'] 
        }
        # Test for really long float numbers
        stub.get('/v1/listings/1000?ApiSig=SignedToken&AuthToken=1234') { [200, {}, '{"D": {
          "Success": true, 
          "Results": [{
            "ResourceUri":"/v1/listings/20101103161209156282000000",
            "StandardFields":{
              "BuildingAreaTotal":0.000000000000000000000000001,
              "ListPrice":9999999999999999999999999.99
            }
          }]}
          }'] 
        }
        # TEST escaped paths
        stub.get('/v1/test%20path%20with%20spaces?ApiSig=SignedToken&AuthToken=1234') { [200, {}, '{"D": {
          "Success": true,
          "Results": []
          }
          }'] 
        }

      end
      @connection = test_connection(stubs)
    end  

    context "when successfully authenticated" do
      subject do 
        class RequestTest
          include SparkApi::Request
          
          attr_accessor *SparkApi::Configuration::VALID_OPTION_KEYS
          attr_accessor :authenticator
          def initialize(session)
            @authenticator=MockApiAuthenticator.new(self)
            @authenticator.session=session
          end
          def authenticate()
            raise "Should not be invoked #{@session.inspect}"
          end
          def authenticated?
            true
          end
          def version()
            "v1"
          end
          attr_accessor :connection
        end
        my_s = mock_session()
        r = RequestTest.new(my_s)
        r.connection = @connection
        r
      end
      it "should get a service" do
        subject.get('/system')[0]["Name"].should == "My User"
      end
      it "should get a service with parameters" do
        subject.get('/marketstatistics/price', "Options" => "ActiveAverageListPrice")[0]["ActiveAverageListPrice"].should == [100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000]
      end
      it "should post to a service" do
        data = {"Contacts" => [{"DisplayName"=>"Wades Contact","PrimaryEmail"=>"wade11@fbsdata.com"}]}
        subject.post('/contacts', data)[0]["ResourceUri"].should == "1000"
      end
      it "should put to a service" do
        # This is a hypothetical unsupported service action at this time
        data = {"Contacts" => [{"DisplayName"=>"WLMCEWENS Contact","PrimaryEmail"=>"wlmcewen789@fbsdata.com"}]}
        subject.put('/contacts/1000', data).size.should be(0)
        # No validation here, if no error is raised, everything is hunky dory
      end
      it "should delete from a service" do
        # This is a hypothetical unsupported service action at this time
        subject.delete('/contacts/1000').size.should be(0)
        # No validation here, if no error is raised, everything is hunky dory
      end
      
      it "should escape a path correctly" do
        subject.get('/test path with spaces').length.should == 0
        # now try this with an already escaped path.  Kaboom!
        expect { subject.get('/test%20path%20with%20spaces') }.to raise_error()
      end
      
      it "post data should support non json data" do
        # Other MISC requests
        subject.post('/stringdata', 'I am a lonely String!').success?.should == true
      end

      it "should allow response object to be returned instead of body" do
        r = subject.get('/system', { full_response: true })

        r.is_a?(Faraday::Response).should be(true)
        r.status.should eq(200)
      end

      it "should give me BigDecimal results for large floating point numbers" do
        MultiJson.default_adapter.should eq(:yajl) unless jruby?
        result = subject.get('/listings/1000')[0]
        result["StandardFields"]["BuildingAreaTotal"].should be_a(Float)
        skip("our JSON parser does not support large decimal types.  Anyone feel like writing some c code?") do
          result["StandardFields"]["BuildingAreaTotal"].should be_a(BigDecimal)
          number = BigDecimal.new(result["StandardFields"]["BuildingAreaTotal"].to_s)
          number.to_s.should eq(BigDecimal.new("0.000000000000000000000000001").to_s)
          number = BigDecimal.new(result["StandardFields"]["ListPrice"].to_s)
          number.to_s.should eq(BigDecimal.new("9999999999999999999999999.99").to_s)
        end
      end
      
    end
    
    context "when unauthenticated" do
      subject do 
        class RequestAuthTest
          include SparkApi::Request
          attr_accessor *SparkApi::Configuration::VALID_OPTION_KEYS
          attr_accessor :authenticator
          def initialize()
            @authenticator=MockApiAuthenticator.new(self)
          end
          def authenticate()
            @authenticator.session ||= mock_session()
          end
          def authenticated?
            @authenticator.authenticated?
          end
          def sign_token(path, params = {}, post_data="")
            "SignedToken"
          end
          def version()
            "v1"
          end
          attr_accessor :connection
        end
        r = RequestAuthTest.new
        r.connection = @connection
        r
      end
      it "should authenticate and then get a service" do
        subject.get('/system')[0]["Name"].should == "My User"
      end
      it "should authenticate and then post to a service" do
        data = {"Contacts" => [{"DisplayName"=>"Wades Contact","PrimaryEmail"=>"wade11@fbsdata.com"}]}
        subject.post('/contacts', data)[0]["ResourceUri"].should == "1000"
      end
    end

    context "when expired" do
      subject do 
        class RequestExpiredTest
          include SparkApi::Request
          attr_accessor *SparkApi::Configuration::VALID_OPTION_KEYS
          attr_accessor :authenticator
          def initialize(session)
            @authenticator=MockApiAuthenticator.new(self)
            @authenticator.session=session
            @reauthenticated = false
          end
          def authenticate()
            @reauthenticated = true
            @authenticator.session = mock_session()
          end
          def authenticated?
            @authenticator.authenticated?
          end
          
          def sign_token(path, params = {}, post_data="")
            "SignedToken"
          end
          def version()
            "v1"
          end
          def reauthenticated?
            @reauthenticated == true
          end
          attr_accessor :connection
        end
        r = RequestExpiredTest.new(mock_expired_session())
        r.connection = @connection
        r
      end
      it "should reauthenticate and then get a service" do
        subject.get('/system')[0]["Name"].should == "My User"
        subject.reauthenticated?.should == true
      end
      it "should reauthenticate and then post to a service" do
        data = {"Contacts" => [{"DisplayName"=>"Wades Contact","PrimaryEmail"=>"wade11@fbsdata.com"}]}
        subject.post('/contacts', data)[0]["ResourceUri"].should == "1000"
        subject.reauthenticated?.should == true
      end
    end

    context "when expire response" do
      subject do 
        session = SparkApi::Authentication::Session.new("AuthToken" => "EXPIRED", "Expires" => (Time.now - 3600).to_s, "Roles" => "['idx']")
        r = RequestExpiredTest.new(session)
        r.connection = @connection
        r
      end
      it "should reauthenticate and then get a service" do
        subject.get('/system')[0]["Name"].should == "My User"
        subject.reauthenticated?.should == true
      end
      it "should reauthenticate and then post to a service" do
        data = {"Contacts" => [{"DisplayName"=>"Wades Contact","PrimaryEmail"=>"wade11@fbsdata.com"}]}
        subject.post('/contacts', data)[0]["ResourceUri"].should == "1000"
        subject.reauthenticated?.should == true
      end
    end

    context "when the server is being a real jerk on expire response" do
      subject do 
        class RequestAlwaysExpiredJerkTest
          include SparkApi::Request
          attr_accessor *SparkApi::Configuration::VALID_OPTION_KEYS
          attr_accessor :authenticator
          def initialize()
            @authenticator=MockApiAuthenticator.new(self)
            @reauthenticated = 0
          end
          def authenticate()
            @reauthenticated += 1
            @authenticator.session = SparkApi::Authentication::Session.new("AuthToken" => "EXPIRED", "Expires" => (Time.now + 60).to_s, "Roles" => "['idx']")
          end
          def authenticated?
            @authenticator.authenticated?
          end
          def sign_token(path, params = {}, post_data="")
            "SignedToken"
          end
          def version()
            "v1"
          end
          def reauthenticated
            @reauthenticated
          end
          attr_accessor :connection
        end
        r = RequestAlwaysExpiredJerkTest.new
        r.connection = @connection
        r
      end
      it "should fail horribly on a get" do
        expect { subject.get('/system')}.to raise_error(SparkApi::PermissionDenied) do |e| 
          e.code.should == SparkApi::ResponseCodes::SESSION_TOKEN_EXPIRED
          e.request_path.should == '/system'
        end
        subject.reauthenticated.should == 2

      end
      it "should fail horribly on a post" do
        data = {"Contacts" => [{"DisplayName"=>"Wades Contact","PrimaryEmail"=>"wade11@fbsdata.com"}]}
        expect { subject.post('/contacts', data)}.to raise_error(SparkApi::PermissionDenied) do |e| 
          e.code.should == SparkApi::ResponseCodes::SESSION_TOKEN_EXPIRED
          e.request_path.should == '/contacts'
        end
        subject.reauthenticated.should == 2
      end
    end
    
  end
  
end
