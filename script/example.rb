#!/usr/bin/env ruby
require "rubygems"

Bundler.require(:default, "test") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

FlexmlsApi.logger.info("Hello!")

FlexmlsApi.configure do |config|
  config.api_key = "fvt_agent_key"
  config.api_secret = "TopSecret"
  config.version = "v1"
  config.endpoint = "https://api.wade.dev.fbsdata.com"
end

client = FlexmlsApi.client

list = client.get '/contacts'
puts "client: #{list.inspect}"
list = FlexmlsApi::Models::Contact.get
puts "model: #{list.inspect}"



