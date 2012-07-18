#!/usr/bin/env ruby
require "rubygems"

Bundler.require(:default, "development") if defined?(Bundler)

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/spark_api'

SparkApi.logger.info("Hello!")

SparkApi.configure do |config|
  config.authentication_mode = SparkApi::Authentication::OAuth2
  config.api_key      = "YOUR_CLIENT_ID"
  config.api_secret   = "YOUR_CLIENT_SECRET"
  config.callback     = "YOUR_REDIRECT_URI"
  config.version      = "v1"
  config.endpoint     = "https://developers.sparkapi.com"
  config.auth_endpoint = "https://developers.sparkplatform.com/oauth2"
end

client = SparkApi.client


# Step 1:
# To get your code to post to /v1/oauth2/grant, send the end user to this URI, replacing the all-capped strings with
# the CGI-escaped credentials for your key:
# https://developers.sparkplatform.com/oauth2?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI
# When the user has finished, they will land at:
# YOUR_REDIRECT_URI?code=CODE.
puts "Go here and log in to get your code: #{client.authenticator.authorization_url}"

# Step 2: Uncomment the following, and add your code in place of CODE_FROM_ABOVE_URI
#         Hold on to the tokens.  Unless you lose them, you can now pass in these 
#         values until the access_token expires.
#client.oauth2_provider.code = "CODE_FROM_ABOVE_URI"
#client.authenticate
#puts "Access Token: #{client.session.access_token}, Refresh Token: #{client.session.refresh_token}"


# Step 3: Comment out Step 2, and uncomment the following.
#         Pass in your access_token and refresh_token to make authenticated requests to the API
#client.session = SparkApi::Authentication::OAuthSession.new "access_token"=> "ACCESS_TOKEN", 
#                    "refresh_token" => "REFRESH_TOKEN", "expires_in" => 86400


# Step 2a and 3a: Uncomment with Step 2 and 3.
#                 Make requests for authorized listing data
#list = client.get '/contacts'
#puts "client: #{list.inspect}"
#list = SparkApi::Models::Contact.get
#puts "model: #{list.inspect}"




