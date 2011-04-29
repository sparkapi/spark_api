#!/usr/bin/env ruby
require "rubygems"
require "bundler"
require 'cgi'
require 'curb'

#Bundler.require(:default, "test") if defined?(Bundler)

CONSUMER_KEY = "974x9ezoqe9jq88kw1nutsswy"
CONSUMER_SECRET = "8myxdoc70kg2h5h3xoxwuvblz"
CALLBACK="http://frink.fbsdata.com/~wade/oauth/"
SITE = "http://farnsworth.fbsdata.com:3012/oauth/authorize"


c = Curl::Easy.http_post("#{SITE}?client_id=#{CONSUMER_KEY}&grant_type=token&redirect_uri=#{CGI.escape(CALLBACK)}&scope=read_notes") do |curl| 
  curl.headers["User-Agent"] = "myapp-1.0"
  curl.headers["Accept"] = "application/json"
  curl.verbose = true
end

access_token="45o2t4a2xbvz85ss9aox59xxy"
#&scope=read_notes


c.perform()
puts c.body_str

me = "http://farnsworth.fbsdata.com:3012/me"
c = Curl::Easy.new("#{me}?access_token=#{access_token}&scope=read_notes") do |curl| 
  curl.headers["User-Agent"] = "myapp-1.0"
  curl.verbose = true
end
c.perform()
puts c.body_str

#c = Curl::Easy.perform("#{SITE}?client_id=#{CONSUMER_KEY}&client_secret=#{CONSUMER_SECRET}&redirect_uri=#{CALLBACK}&response_type=token")

#puts c.body_str
  
  
#@access_token = @request_token.get_access_token

#@photos = @access_token.get('/photos.xml')
#
#oauth_params = {:consumer => oauth_consumer, :token => access_token}
#hydra = Typhoeus::Hydra.new
#req = Typhoeus::Request.new(uri, options)
#oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => uri))
#req.headers.merge!({"Authorization" => oauth_helper.header}) # Signs the request
#hydra.queue(req)
#hydra.run
#@response = req.response
