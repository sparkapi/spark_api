require './spec/spec_helper'

describe FlexmlsApi do
  describe FlexmlsApi::ClientError do
    subject { FlexmlsApi::ClientError.new("1234", 200) }
    it "should have an api code" do
      subject.code.should == "1234"
    end
    it "should have an http status" do
      subject.status.should == 200
    end
    it "should raise and exception with attached message" do
      expect { raise subject, "My Message" }.to raise_error(FlexmlsApi::ClientError){ |e| e.message.should == "My Message" }
    end
  end

  describe FlexmlsApi::ApiResponse do
    it "should asplode if given an invalid  or empty response" do
      expect { FlexmlsApi::ApiResponse.new("KABOOOM") }.to raise_error(FlexmlsApi::InvalidResponse)
      expect { FlexmlsApi::ApiResponse.new({"D"=>{}}) }.to raise_error(FlexmlsApi::InvalidResponse)
    end
    it "should have results when successful" do
      r = FlexmlsApi::ApiResponse.new({"D"=>{"Success" => true, "Results" => []}})
      r.success?.should be true
      r.results.empty?.should be true
    end
    it "should have a message on error" do
      r = FlexmlsApi::ApiResponse.new({"D"=>{"Success" => false, "Message" => "I am a failure."}})
      r.success?.should be false
      r.message.should be == "I am a failure."
    end
  end
  
  describe FlexmlsApi::Request do
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
      end
      @connection = test_connection(stubs)
    end  

    context "when successfully authenticated" do
      subject do 
        class RequestTest
          include FlexmlsApi::Request
          def initialize(session)
            @session = session
          end
          def authenticate()
            raise "Should not be invoked #{@session.inspect}"
          end
          def sign_token(path, params = {}, post_data="")
            "SignedToken"
          end
          def version()
            "v1"
          end
          def empty_parameters()
            build_url_parameters()
          end
          attr_accessor :connection
        end
        my_s = mock_session()
        r = RequestTest.new(my_s)
        r.connection = @connection
        r
      end
      it "should give me empty string when no parameters" do
        subject.empty_parameters().should == ""
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
        subject.put('/contacts/1000', data).should be nil
        # No validation here, if no error is raised, everything is hunky dory
      end
      it "should delete from a service" do
        # This is a hypothetical unsupported service action at this time
        subject.delete('/contacts/1000').should be nil
        # No validation here, if no error is raised, everything is hunky dory
      end
    end
    
    context "when unauthenticated" do
      subject do 
        class RequestAuthTest
          include FlexmlsApi::Request
          def authenticate()
            @session ||= mock_session()
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
          include FlexmlsApi::Request
          def initialize(session)
            @session = session
            @reauthenticated = false
          end
          def authenticate()
            @reauthenticated = true
            @session = mock_session()
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
        session = FlexmlsApi::Authentication::Session.new("AuthToken" => "EXPIRED", "Expires" => (Time.now + 60).to_s, "Roles" => "['idx']")
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
          include FlexmlsApi::Request
          def initialize()
            @reauthenticated = 0
          end
          def authenticate()
            @reauthenticated += 1
            @session = session = FlexmlsApi::Authentication::Session.new("AuthToken" => "EXPIRED", "Expires" => (Time.now + 60).to_s, "Roles" => "['idx']")
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
        expect { subject.get('/system')}.to raise_error(FlexmlsApi::PermissionDenied){ |e| e.code.should == FlexmlsApi::ResponseCodes::SESSION_TOKEN_EXPIRED }
        subject.reauthenticated.should == 2
      end
      it "should fail horribly on a post" do
        data = {"Contacts" => [{"DisplayName"=>"Wades Contact","PrimaryEmail"=>"wade11@fbsdata.com"}]}
        expect { subject.post('/contacts', data)}.to raise_error(FlexmlsApi::PermissionDenied){ |e| e.code.should == FlexmlsApi::ResponseCodes::SESSION_TOKEN_EXPIRED }
        subject.reauthenticated.should == 2
      end
    end
    
  end

end
