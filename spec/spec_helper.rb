require "rubygems"
require "json"
require 'multi_json'
require "rspec"
require 'rspec/autorun'
require 'webmock/rspec'

begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/spark_api'

require 'spark_api'
require File.expand_path('../mock_helper', __FILE__)
require File.expand_path('../json_helper', __FILE__)
require File.expand_path('../json_hash_test_support', __FILE__)


FileUtils.mkdir 'log' unless File.exists? 'log'

# TODO, really we should change the library to support configuration without overriding
module SparkApi
  def self.logger
    if @logger.nil?
      @logger = Logger.new('log/test.log')
      @logger.level = Logger::DEBUG
    end
    @logger
  end
end

SparkApi.logger.info("Setup gem for rspec testing")

include SparkApi::Models

def reset_config
  SparkApi.reset
  SparkApi.configure { |c| c.api_user = "foobar" }
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.alias_example_to :on_get_it, :method => 'GET'
  config.alias_example_to :on_put_it, :method => 'PUT'
  config.alias_example_to :on_post_it, :method => 'POST'
  config.alias_example_to :on_delete_it, :method => 'DELETE'
  config.before(:all) { reset_config }
end
