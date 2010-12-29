require "rubygems"
require "json"
require "rspec"
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

require 'flexmls_api'

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


class MockClient < FlexmlsApi::Client
  attr_accessor :connection, :session
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
