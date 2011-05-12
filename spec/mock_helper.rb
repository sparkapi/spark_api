
Rspec.configure do |config|
  config.include WebMock::API
end

$test_client = FlexmlsApi::Client.new({:api_key=>"", :api_secret=>""})
def stub_api_get(service_path, stub_fixture="success.json", opts={})
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{FlexmlsApi.version}#{service_path}", params)
  s=stub_request(:get, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig        
        }.merge(params)).
      to_return(:body => fixture(stub_fixture))
end
def stub_api_delete(service_path, stub_fixture="success.json", opts={})
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{FlexmlsApi.version}#{service_path}", params)
  s=stub_request(:delete, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig        
        }.merge(params)).
      to_return(:body => fixture(stub_fixture))
end
def stub_api_post(service_path, body, stub_fixture="success.json", opts={})
  body_str = fixture(body).read
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{FlexmlsApi.version}#{service_path}", params, body_str)
  s=stub_request(:post, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig        
        }.merge(params),
        :body => body_str
      ).
      to_return(:body => fixture(stub_fixture))
end
def stub_api_put(service_path, body, stub_fixture="success.json", opts={})
  body_str = fixture(body).read
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{FlexmlsApi.version}#{service_path}", params, body_str)
  s=stub_request(:put, "#{FlexmlsApi.endpoint}/#{FlexmlsApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig        
        }.merge(params),
        :body => body_str
      ).
      to_return(:body => fixture(stub_fixture))
end


def mock_session()
  FlexmlsApi::Authentication::Session.new("AuthToken" => "1234", "Expires" => (Time.now + 3600).to_s, "Roles" => "['idx']")
end

def mock_oauth_session()
  FlexmlsApi::Authentication::OAuthSession.new("access_token" => "1234", "expires_in" => 3600, "scope" => nil, "refresh_token"=> "1000refresh")
end

class MockClient < FlexmlsApi::Client
  attr_accessor :connection
  def connection(ssl = false)
    @connection
  end
end

class MockApiAuthenticator < FlexmlsApi::Authentication::ApiAuth
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
  FlexmlsApi::Authentication::Session.new("AuthToken" => "1234", "Expires" => (Time.now - 60).to_s, "Roles" => "['idx']")
end

def test_connection(stubs)
  Faraday::Connection.new(nil, {:headers => FlexmlsApi::Client.new.headers}) do |builder|
    builder.adapter :test, stubs
    builder.use Faraday::Response::ParseJson
    builder.use FlexmlsApi::FaradayExt::FlexmlsMiddleware
  end
end

def stub_auth_request()
  stub_request(:post, "https://api.flexmls.com/#{FlexmlsApi.version}/session").
              with(:query => {:ApiKey => "", :ApiSig => "806737984ab19be2fd08ba36030549ac"}).
              to_return(:body => fixture("session.json"))
end

def fixture(file)
  File.new(File.expand_path("../fixtures", __FILE__) + '/' + file)
end

