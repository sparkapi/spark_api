flexmls API
=====================


Off the cuff example
----------------------
require 'flexmls_api'  # put this in your Gemfile if you're using builder
FlexmlsApi.configure do |config|
  config.api_key = "your_key_here"
  config.api_secret = "your_api_secret"
  config.version = "v1"                        
  config.endpoint = "https://api.flexmls.com"  
end

l = FlexmlsApi::Listing.find(1234)  # returns an instance of FlexmlsApi::Listing
