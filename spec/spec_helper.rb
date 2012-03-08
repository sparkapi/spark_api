require "rubygems"
require "json"
require "rspec"
require 'rspec/autorun'
require 'webmock/rspec'

begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

require 'flexmls_api'
require File.expand_path('../mock_helper', __FILE__)
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

def reset_config()
  FlexmlsApi.reset
  FlexmlsApi.configure do |config|
    config.api_user = "foobar"
  end
end
reset_config

include FlexmlsApi::Models

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.alias_example_to :on_get_it, :method => 'GET'
  config.alias_example_to :on_put_it, :method => 'PUT'
  config.alias_example_to :on_post_it, :method => 'POST'
  config.alias_example_to :on_delete_it, :method => 'DELETE'
end
