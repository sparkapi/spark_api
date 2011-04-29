require "rubygems"
require "json"
require "rspec"
require 'webmock/rspec'


Rspec.configure do |config|
  config.include WebMock::API
end

begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

require 'flexmls_api'
require File.expand_path('../json_helper', __FILE__)


FileUtils.mkdir 'log' unless File.exists? 'log'

# TODO, really we should change the library to support configuration without overriding
module FlexmlsApi
  def self.logger
    if @logger.nil?
      @logger = Logger.new('log/test.log')
      @logger.level = Logger::DEBUG
    end
    @logger
  end
end

FlexmlsApi.logger.info("Setup gem for rspec testing")

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

def reset_config()
  FlexmlsApi.reset
  FlexmlsApi.configure do |config|
    config.api_user = "foobar"
  end
end
reset_config

include FlexmlsApi::Models
