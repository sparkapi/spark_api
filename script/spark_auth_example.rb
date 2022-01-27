#!/usr/bin/env ruby
require "rubygems"

Bundler.require(:default, "development") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/spark_api'

SparkApi.logger.info("Hello!")

  #### COPY/PASTE YOUR API KEY AND SECRET BELOW
SparkApi.configure do |config|
  config.api_key = "agent_key"
  config.api_secret = "agent_secret"
  config.version = "v1"
  config.endpoint = "https://api.sparkapi.com"
end

client = SparkApi.client

list = client.get '/contacts'
puts "client: #{list.inspect}"
list = SparkApi::Models::Contact.get
puts "model: #{list.inspect}"

