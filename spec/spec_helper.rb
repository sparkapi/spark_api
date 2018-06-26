require "rubygems"
require "rspec"
require 'webmock/rspec'
require 'spark_api'

if ENV['COVERAGE'] == "on"
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start { add_filter %w(/vendor /spec /test) }
end

FileUtils.mkdir 'log' unless File.exists? 'log'

include SparkApi::Models
SparkApi.logger = ::Logger.new('log/test.log')

# Requires supporting ruby files with custom matchers and macros, etc,
# # in spec/support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  config.include WebMock::API
  config.include StubApiRequests

  config.alias_example_to :on_get_it, :method => 'GET'
  config.alias_example_to :on_put_it, :method => 'PUT'
  config.alias_example_to :on_post_it, :method => 'POST'
  config.alias_example_to :on_delete_it, :method => 'DELETE'
  config.before(:all) { reset_config }
  config.color= true
end

def jruby? 
  RUBY_PLATFORM == "java"
end

def reset_config
  SparkApi.reset
  SparkApi.configure { |c| c.api_user = "foobar" }
end
