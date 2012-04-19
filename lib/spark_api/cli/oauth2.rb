require File.dirname(__FILE__) + "/../cli/setup"

SparkApi.configure do |config|
  config.oauth2_provider = SparkApi::Authentication::OAuth2Impl::PasswordProvider.new(
                            :authorization_uri=> ENV["AUTH_URI"],
                            :access_uri  => ENV["ACCESS_URI"],
                            :username=> ENV["USERNAME"],
                            :password=> ENV["PASSWORD"],
                            :client_id=> ENV["CLIENT_ID"],
                            :client_secret=> ENV["CLIENT_SECRET"]
                          ) 
  config.authentication_mode = SparkApi::Authentication::OAuth2
  config.endpoint = ENV["API_ENDPOINT"] if ENV["API_ENDPOINT"]
end
