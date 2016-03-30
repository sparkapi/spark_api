if ENV['COVERAGE'] == "on"
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start do
    add_filter '/vendor'
    add_filter '/spec'
    add_filter '/test'
  end
end

require "rubygems"
require "rspec"
require 'rspec/autorun'
require 'webmock/rspec'
require "json"
require 'multi_json'

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/spark_api'

require 'spark_api'

FileUtils.mkdir 'log' unless File.exists? 'log'

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

# Requires supporting ruby files with custom matchers and macros, etc,
# # in spec/support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.alias_example_to :on_get_it, :method => 'GET'
  config.alias_example_to :on_put_it, :method => 'PUT'
  config.alias_example_to :on_post_it, :method => 'POST'
  config.alias_example_to :on_delete_it, :method => 'DELETE'
  config.before(:all) { reset_config }
  config.color_enabled = true
end

def jruby? 
  RUBY_PLATFORM == "java"
end
