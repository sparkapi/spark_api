#!/usr/bin/env ruby
require "rubygems"

Bundler.require(:default, "test") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

FlexmlsApi.logger.info("Hello!")

client = FlexmlsApi::Client.new(:api_key => "key_of_wade", :api_secret => "TopSecret", :endpoint => "https://api.wade.dev.fbsdata.com")

client.authenticate

sys = client.get '/v1/system'

puts "I can haz system!  #{sys}"


