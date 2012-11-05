RSpec.configure do |config|
  config.include WebMock::API
end

$test_client = SparkApi::Client.new({:api_key=>"", :api_secret=>""})

def stub_api_get(service_path, stub_fixture="success.json", opts={})
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{SparkApi.version}#{service_path}", params)
  s=stub_request(:get, "#{SparkApi.endpoint}/#{SparkApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig        
        }.merge(params))
  if(block_given?)
    yield s
  else
    s.to_return(:body => fixture(stub_fixture))
  end
  log_stub(s)
end
def stub_api_delete(service_path, stub_fixture="success.json", opts={})
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{SparkApi.version}#{service_path}", params)
  s=stub_request(:delete, "#{SparkApi.endpoint}/#{SparkApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig
        }.merge(params))
  if(block_given?)
    yield s
  else
    s.to_return(:body => fixture(stub_fixture))
  end
  log_stub(s)
end
def stub_api_post(service_path, body, stub_fixture="success.json", opts={})
  if body.is_a?(Hash)
    body = { :D => body } unless body.empty? 
  elsif !body.nil?
    body = MultiJson.load(fixture(body).read)
  end
  body_str = body.nil? ? body : MultiJson.dump(body)
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{SparkApi.version}#{service_path}", params, body_str)
  s=stub_request(:post, "#{SparkApi.endpoint}/#{SparkApi.version}#{service_path}").
      with(:query => {
        :ApiSig => sig        
        }.merge(params),
        :body => body
      )
  if(block_given?)
    yield s
  else
    s.to_return(:body => fixture(stub_fixture))
  end
  log_stub(s)
end
def stub_api_put(service_path, body, stub_fixture="success.json", opts={})
  if body.is_a? Hash
    body = { :D => body }
  elsif !body.nil?
    body = MultiJson.load(fixture(body).read)
  end
  body_str = body.nil? ? body : MultiJson.dump(body)
  params = {:ApiUser => "foobar", :AuthToken => "c401736bf3d3f754f07c04e460e09573"}.merge(opts)
  sig = $test_client.authenticator.sign_token("/#{SparkApi.version}#{service_path}", params, body_str)
  full_path = "#{SparkApi.endpoint}/#{SparkApi.version}#{service_path}"
  s=stub_request(:put, full_path).with(:query => {
        :ApiSig => sig
        }.merge(params),
        :body => body
      )
  if(block_given?)
    yield s
  else
    s.to_return(:body => fixture(stub_fixture))
  end
  log_stub(s)
end

def log_stub(s)
  SparkApi.logger.debug("Stubbed Request: #{s.inspect} \n\n")
  return s
end

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

