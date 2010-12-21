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
  FlexmlsApi::Authentication::Session.new("AuthToken" => "1234", "Expires" => (Time.now + 1/24.0).to_s, "Roles" => "['idx']")
end

def mock_expired_session()
  FlexmlsApi::Authentication::Session.new("AuthToken" => "1234", "Expires" => (Time.now - 1/1440.0).to_s, "Roles" => "['idx']")
end
