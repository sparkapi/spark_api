require "spark_api"

SparkApi.configure do |config|
  config.endpoint   = 'https://sparkapi.com'
  config.authentication_mode = SparkApi::Authentication::OAuth2  
end

  #### COPY/PASTE YOUR ACCESS TOKEN WHERE DESIGNATED BELOW 
SparkApi.client.session = SparkApi::Authentication::OAuthSession.new({ :access_token => "your_access_token_here" })

client = SparkApi.client

list = client.get '/contacts'
puts "client: #{list.inspect}"
list = SparkApi::Models::Contact.get
puts "model: #{list.inspect}"
