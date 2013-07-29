Spark API
=====================
[![Build Status](https://travis-ci.org/sparkapi/spark_api.png?branch=master)](http://travis-ci.org/sparkapi/spark_api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/sparkapi/spark_api)

A Ruby wrapper for the Spark REST API. Loosely based on ActiveResource to provide models to interact with remote services.


Documentation
-------------

For further client documentation, please consult our [wiki](/sparkapi/spark_api/wiki).

For full information on the API, see [http://sparkplatform.com/docs/overview/api](http://sparkplatform.com/docs/overview/api)


Installation
---------
    gem install spark_api

Usage Examples
------------------------
    SparkApi.configure do |config|
      config.endpoint   = 'https://sparkapi.com'
      # Using Spark API Authentication, refer to the Authentication documentation for OAuth2
      config.api_key    = 'MY_SPARK_API_KEY'
      config.api_secret = 'MY_SPARK_API_SECRET'
    end
    SparkApi.client.get '/my/account'


#### Interactive Console
Included in the gem is an interactive spark_api console to interact with the api in a manner similar to the rails console. Below is a brief example of interacting with the console:

    > spark_api --api_key MY_SPARK_API_KEY --api_secret MY_SPARK_API_SECRET
    SparkApi> SparkApi.client.get '/my/account'

Using OAuth2 requires different arguments, and is a bit more complicated as it requires a step for logging in through the browser to gain access to the access code for a client_id. 

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

You can also provide other options from the command line, see "spark_api -h" for more information.

#### HTTP Interface
The base client provides a bare bones HTTP interface for working with the RESTful Spark API. This is basically a stylized curl interface that handles authentication, error handling, and processes JSON results as Ruby Hashes.

    SparkApi.client.get     "/listings/#{listing_id}", :_expand => "CustomFields"
    SparkApi.client.post    "/listings/#{listing_id}/photos", photo_body_hash
    SparkApi.client.put     "/listings/#{listing_id}/photos/#{photo_id}", updated_photo_name_hash
    SparkApi.client.delete  "/listings/#{listing_id}/photos/#{photo_id}"

#### [API Models](/sparkapi/spark_api/wiki/API-Models)
The client also provides ActiveModelesque interface for working with the api responses. Notably, the models use finder methods for searching, and similar instanciation and persistence also on supported services.

    # Tip: mixin the models so you can use them without namespaces
    include SparkApi::Models
    listings = Listing.find(:all, :_filter => "ListPrice Gt 150000.0 And ListPrice Lt 200000.0", :_orderby => "-ListPrice")
    puts "Top list price: $%.2f" % listings.first.ListPrice
    # Top list price: $199999.99
    puts Account.find(:first, :_filter => "UserType Eq 'Member' And Name Eq 'John*'").Name
    # John Doe
    

JSON Parsing
--------------
By default, this gem uses the pure ruby json gem for parsing API responses for cross platform compatibility. Projects that include the yajl-ruby gem will see noticeable speed improvements when installed.


Authentication Types
--------------
Authentication is handled transparently by the request framework in the gem, so you should never need to manually make an authentication request.  More than one mode of authentication is supported, so the client needs to be configured accordingly.

#### [Spark API Authentication](/sparkapi/spark_api/wiki/Spark-Authentication) (Default)
Usually supplied for a single user, this authentication mode is the simplest, and is setup as the default.  The example usage above demonstrates how to get started using this authentication mode.

#### [OpenId/OAuth2 Combined Flow](/sparkapi/spark_api/wiki/Hybrid-Authentication) (Preferred)
Authorization mode the separates application and user authentication.  This mode requires the end user to be redirected to Spark Platform's openid endpoint.  See "script/combined_flow_example.rb" for an example.

Read more about Spark Platform's combined flow <a href="http://sparkplatform.com/docs/authentication/openid_oauth2_authentication">here</a>.

#### [OAuth2 Authorization](/sparkapi/spark_api/wiki/OAuth2-Only-Authentication)
Authorization mode the separates application and user authentication.  This mode requires the end user to be redirected to Spark Platform's auth endpoint.  See "script/oauth2_example.rb" for an example.

Read more about Spark Platform's OAuth 2 flow <a href="http://sparkplatform.com/docs/authentication/oauth2_authentication">here</a>.
