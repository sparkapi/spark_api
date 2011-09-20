require File.dirname(__FILE__) + "/../cli/setup"

FlexmlsApi.configure do |config|
  config.api_key = ENV["API_KEY"] 
  config.api_secret = ENV["API_SECRET"]
  config.api_user = ENV["API_USER"] if ENV["API_USER"]
  config.endpoint = ENV["API_ENDPOINT"] if ENV["API_ENDPOINT"]
end
