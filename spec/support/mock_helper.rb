def mock_session()
  SparkApi::Authentication::Session.new("AuthToken" => "1234", "Expires" => (Time.now + 3600).to_s, "Roles" => "['idx']")
end

def mock_oauth_session()
  SparkApi::Authentication::OAuthSession.new("access_token" => "1234", "expires_in" => 3600, "scope" => nil, "refresh_token"=> "1000refresh")
end

class MockClient < SparkApi::Client
  attr_accessor :connection
  def connection(ssl = false)
    @connection
  end
end

class MockApiAuthenticator < SparkApi::Authentication::ApiAuth
  # Sign a request
  def sign(sig)
    "SignedToken"
  end
end

def mock_client(stubs)
  c = MockClient.new
  c.session = mock_session()
  c.connection = test_connection(stubs)
  c
end

def mock_expired_session()
  SparkApi::Authentication::Session.new("AuthToken" => "1234", "Expires" => (Time.now - 60).to_s, "Roles" => "['idx']")
end

def test_connection(stubs)
  Faraday.new(nil, {:headers => SparkApi::Client.new.headers}) do |conn|
    conn.response :spark_api
    conn.adapter :test, stubs
  end
end

def stub_auth_request()
  stub_request(:post, "#{SparkApi.endpoint}/#{SparkApi.version}/session").
              with(:query => {:ApiKey => "", :ApiSig => "806737984ab19be2fd08ba36030549ac"}).
              to_return(:body => fixture("session.json"))
end

def fixture(file)
  File.new(File.expand_path("../../fixtures", __FILE__) + '/' + file)
end

