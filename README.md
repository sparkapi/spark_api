Spark API
=====================
![CI](https://github.com/sparkapi/spark_api/workflows/CI/badge.svg) 

A Ruby wrapper for the Spark REST API. Loosely based on ActiveResource to provide models to interact with remote services.


Documentation
-------------

For further client documentation, please consult our [wiki](https://github.com/sparkapi/spark_api/wiki).

For full information on the Spark API, see [http://sparkplatform.com/docs/overview/api](http://sparkplatform.com/docs/overview/api). If you would instead like information on the RESO Web API, see [http://sparkplatform.com/docs/reso/overview](http://sparkplatform.com/docs/reso/overview)


Installation
---------
    gem install spark_api


Authentication Types
--------------
Authentication is handled transparently by the request framework in the gem, so you should never need to manually make an authentication request.  More than one mode of authentication is supported, so the client needs to be configured accordingly.

#### [Access Token Authentication](https://github.com/sparkapi/spark_api/wiki/Spark-Authentication) (Preferred)
Also known as Bearer Token Authentication. If you've been provided a single non-expiring access (bearer) token for the purpose of accessing data on behalf of one or more MLS users, this method of authentication should be used. See "script/access_token_example.rb" for an example. 

#### [OpenId/OAuth2 Combined Flow](https://github.com/sparkapi/spark_api/wiki/Hybrid-Authentication)
Authorization mode that separates application and user authentication. This mode requires the end user to be redirected to Spark Platform's openid endpoint in a web browser window. See "script/combined_flow_example.rb" for an example.

Read more about Spark Platform's combined flow <a href="http://sparkplatform.com/docs/authentication/openid_oauth2_authentication">here</a>.

#### [OAuth2 Authorization](https://github.com/sparkapi/spark_api/wiki/OAuth2-Only-Authentication)
Authorization mode that separates application and user authentication. This mode requires the end user to be redirected to Spark Platform's auth endpoint in a web browser window. See "script/oauth2_example.rb" for an example.

Read more about Spark Platform's OAuth 2 flow <a href="http://sparkplatform.com/docs/authentication/oauth2_authentication">here</a>.

#### [Spark API Authentication](https://github.com/sparkapi/spark_api/wiki/Spark-Authentication) (Deprecated)
Usually supplied for a single user, this authentication mode was our old standard, however, is now deprecated in favor of bearer token authentication. See "script/spark_auth_example.rb" for an example. 


Usage Examples
------------------------
#### Accessing the Spark API (Default)
```ruby
require 'spark_api'
SparkApi.configure do |config|
  config.endpoint   = 'https://sparkapi.com'
  config.authentication_mode = SparkApi::Authentication::OAuth2  
end
  #Non-expiring bearer token auth. See below if you are using a different authentication method.
SparkApi.client.session = SparkApi::Authentication::OAuthSession.new({ :access_token => "your_bearer_token_here" })
puts SparkApi.client.get '/system'
```

#### Accessing the RESO Web API
```ruby
require "spark_api"

# set up session and set the client to hit the RESO API endpoints.
SparkApi.configure do |config|
    config.authentication_mode = SparkApi::Authentication::OAuth2
    config.middleware = :reso_api
end
  #Non-expiring bearer token auth. See below if you are using a different authentication method.
SparkApi.client.session = SparkApi::Authentication::OAuthSession.new({ :access_token => "your_access_token_here" })

puts SparkApi.client.get("/Property", {:$top => 10 })
```

The examples above utilize access token authentication. For examples using different authentication methods review the wiki and /script folder within this project.

#### Interactive Console
Included in the gem is an interactive spark_api console to interact with the api in a manner similar to the rails console. Here are a few examples using various auth methods:

Access Token Auth:

    > spark_api --oauth2
    SparkApi:001:0> SparkApi.client.session = SparkApi::Authentication::OAuthSession.new({ :access_token => "your_access_token_here" })
    SparkApi:002:0> SparkApi.client.get '/my/account'

Standard OAuth2 access is a bit more complicated as it requires a step for logging in through the browser to gain access to the access code for a client_id. 

    > bundle exec spark_api --oauth2 --client_id my_oauth2_client_id --client_secret my_oauth2_client_secret 
    Loading spark_api gem...
    SparkApi:001:0> Account.my.Name
    Missing OAuth2 session, redirecting...
    Please visit https://sparkplatform.com/oauth2?client_id=my_oauth2_client_id&response_type=code&redirect_uri=https%3A%2F%2Fsparkplatform.com%2Foauth2%2Fcallback, login as a user, and paste the authorization code here:
    Authorization code?
    9zsrc7jk7m4x7r4kers8n6sp5
    "Demo User"
    SparkApi:002:0> Account.my.UserType
    "Member"

[Spark Auth (deprecated)](http://sparkplatform.com/docs/authentication/spark_api_authentication):

    > spark_api --api_key MY_SPARK_API_KEY --api_secret MY_SPARK_API_SECRET
    SparkApi> SparkApi.client.get '/my/account'

You can also provide other options from the command line, see "spark_api -h" for more information.

#### HTTP Interface
The base client provides a bare bones HTTP interface for working with the RESTful Spark API. This is basically a stylized curl interface that handles authentication, error handling, and processes JSON results as Ruby Hashes.

```ruby
SparkApi.client.get     "/listings", :_expand => "CustomFields", :_filter => "MlsStatus Eq 'Active'", :_limit => 1
SparkApi.client.post    "/listings/#{listing_id}/photos", photo_body_hash
SparkApi.client.put     "/listings/#{listing_id}/photos/#{photo_id}", updated_photo_name_hash
SparkApi.client.delete  "/listings/#{listing_id}/photos/#{photo_id}"
```

#### [API Models](https://github.com/sparkapi/spark_api/wiki/API-Models)
The client also provides ActiveModelesque interface for working with the api responses. Notably, the models use finder methods for searching, and similar instanciation and persistence also on supported services.

```ruby
# Tip: mixin the models so you can use them without namespaces
include SparkApi::Models
listings = Listing.find(:all, :_filter => "ListPrice Gt 150000.0 And ListPrice Lt 200000.0", :_orderby => "-ListPrice")
puts "Top list price: $%.2f" % listings.first.ListPrice

# Top list price: $199999.99
puts Account.find(:first, :_filter => "UserType Eq 'Member' And Name Eq 'John*'").Name
# John Doe
```    

JSON Parsing
--------------
By default, this gem uses the pure ruby json gem for parsing API responses for cross platform compatibility. Projects that include the yajl-ruby gem will see noticeable speed improvements when installed.

