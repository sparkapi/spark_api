#!/usr/bin/env ruby
require "rubygems"

Bundler.require(:default, "development") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/spark_api'

SparkApi.logger.info("Hello!")

SparkApi.configure do |config|
  config.endpoint   = 'https://sparkapi.com'
  config.authentication_mode = SparkApi::Authentication::OAuth2  
end

SparkApi.client.session = SparkApi::Authentication::OAuthSession.new({ :access_token => "your_access_token_here" })

client = SparkApi.client

list = client.get '/contacts'
puts "client: #{list.inspect}"
list = SparkApi::Models::Contact.get
puts "model: #{list.inspect}"



