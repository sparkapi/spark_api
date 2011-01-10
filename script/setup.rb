#!/usr/bin/env ruby
require "rubygems"

Bundler.require(:default, "test") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

FlexmlsApi.logger.info("Client configured!")


FlexmlsApi.configure do |config|
  config.api_key = ENV["API_KEY"] 
  config.api_secret = ENV["API_SECRET"]
  config.version = "v1"
  config.endpoint = "https://api.flexmls.com"
end

include FlexmlsApi::Models


