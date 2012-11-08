require File.dirname(__FILE__) + "/../cli/setup"


SparkApi.configure do |config|
  oauth = {
    :authorization_uri=> ENV.fetch("AUTH_URI", SparkApi::Configuration::DEFAULT_AUTH_ENDPOINT),
    :access_uri  => ENV.fetch("ACCESS_URI", SparkApi::Configuration::DEFAULT_ACCESS_URI),
    :redirect_uri  => ENV.fetch("REDIRECT_URI", SparkApi::Configuration::DEFAULT_REDIRECT_URI),
    :client_id=> ENV["CLIENT_ID"],
    :client_secret=> ENV["CLIENT_SECRET"]
  }
  oauth[:username] = ENV["USERNAME"] if ENV.include?("USERNAME")
  oauth[:password] = ENV["PASSWORD"] if ENV.include?("PASSWORD")
  config.oauth2_provider = SparkApi::Authentication::OAuth2Impl::PasswordProvider.new(oauth)
  unless (oauth.include?(:username) && oauth.include?(:password))
    config.oauth2_provider.grant_type = :authorization_code 
    config.oauth2_provider.code = ENV["CODE"] if ENV.include?("CODE")
  end
  config.authentication_mode = SparkApi::Authentication::OAuth2
  config.endpoint = ENV["API_ENDPOINT"] if ENV["API_ENDPOINT"]
  config.ssl_verify = ! (ENV["NO_VERIFY"].downcase=='true') if ENV["NO_VERIFY"]
end


def persist_sessions! my_alias = nil
  SparkApi.client.oauth2_provider.session_alias = my_alias unless my_alias.nil?
  
  SparkApi.client.oauth2_provider.persistent_sessions = true
end