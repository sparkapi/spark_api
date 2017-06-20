require File.dirname(__FILE__) + "/../cli/setup"

SparkApi.configure do |config|
  config.api_key = ENV["API_KEY"] 
  config.api_secret = ENV["API_SECRET"]
  config.api_user = ENV["API_USER"] if ENV["API_USER"]
  config.endpoint = ENV["API_ENDPOINT"] if ENV["API_ENDPOINT"]
  config.ssl_verify = ENV["SSL_VERIFY"].downcase != 'false' if ENV["SSL_VERIFY"]
  config.middleware = ENV["SPARK_MIDDLEWARE"]  if ENV["SPARK_MIDDLEWARE"]
end
