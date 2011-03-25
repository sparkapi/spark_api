#!/usr/bin/env ruby
require "rubygems"

# This is a handy startup script for working with the client from an irb session.  All you need to 
# do is set "API_KEY" and "API_SECRET" environment variables and run:
#  > irb -r script/setup

Bundler.require(:default, "test") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

FlexmlsApi.logger.info("Client configured!")


FlexmlsApi.configure do |config|
  config.api_key = ENV["API_KEY"] 
  config.api_secret = ENV["API_SECRET"]
  config.api_user = ENV["API_USER"] if ENV["API_USER"]
  config.endpoint = ENV["API_ENDPOINT"] if ENV["API_ENDPOINT"]
end

include FlexmlsApi::Models

