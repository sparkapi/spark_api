Spark API
=====================
A Ruby wrapper for the Spark REST API. Loosely based on ActiveResource to provide models to interact with remote services.


Documentation
-------------
For further client documentation, please consult our [wiki](wiki)
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
Included in the gem is an interactive spark_api console to interact with the api in a manner similar to the rails console. Below is a brief example of interacting with the console

    > spark_api --api_key MY_SPARK_API_KEY --api_secret MY_SPARK_API_SECRET
    SparkApi> SparkApi.client.get '/my/account'

You can also provide other options from the command line, see "spark_api -h" for more information.

#### HTTP Interface
The base client provides a bare bones HTTP interface for working with the RESTful Spark API. This is basically a stylized curl interface that handles authentication, error handling, and processes JSON results as Ruby Hashes.

    SparkApi.client.get     "/listings/#{listing_id}", :_expand => "CustomFields"
    SparkApi.client.post    "/listings/#{listing_id}/photos", photo_body_hash
    SparkApi.client.put     "/listings/#{listing_id}/photos/#{photo_id}", updated_photo_name_hash
    SparkApi.client.delete  "/listings/#{listing_id}/photos/#{photo_id}"

#### [API Models](wiki/API-Models)
The client also provides ActiveModelesque interface for working with the api responses. Notably, the models use finder methods for searching, and similar instanciation and persistence also on supported services.

    # Tip: mixin the models so you can use them without namespaces
    include SparkApi::Models
    listings = Listing.find(:all, :_filter => "ListPrice Gt 150000.0 And ListPrice Lt 200000.0", :_orderby => "-ListPrice")
    puts "Top list price: $%.2f" % listings.first.ListPrice
    # Top list price: $199999.99
    puts Account.find(:first, :_filter => "UserType Eq 'Member' And Name Eq 'John*'").Name
    # John Doe


Authentication Types
--------------
Authentication is handled transparently by the request framework in the gem, so you should never need to manually make an authentication request.  More than one mode of authentication is supported, so the client needs to be configured accordingly.

#### [Spark API Authentication](wiki/Spark-Authentication) (Default)
Usually supplied for a single user, this authentication mode is the simplest, and is setup as the default.  The example usage above demonstrates how to get started using this authentication mode.

#### [OpenId/OAuth2 Combined Flow](wiki/Hybrid-Authentication) (Preferred)
Authorization mode the separates application and user authentication.  This mode requires the end user to be redirected to Spark Platform's openid endpoint.  See "script/combined_flow_example.rb" for an example.

Read more about Spark Platform's combined flow <a href="http://sparkplatform.com/docs/authentication/openid_oauth2_authentication">here</a>.

#### [OAuth2 Authorization](wiki/OAuth2-Only-Authentication)
Authorization mode the separates application and user authentication.  This mode requires the end user to be redirected to Spark Platform's auth endpoint.  See "script/oauth2_example.rb" for an example.

Read more about Spark Platform's OAuth 2 flow <a href="http://sparkplatform.com/docs/authentication/oauth2_authentication">here</a>.

#### [OpenId Authentication](wiki/OpenId-Only-Authentication)
There is also the option to only access a user's Spark Platform identity without accessing any data (e.g. listings, contacts, etc.).  In circumstances where you ONLY with to authenticate users through the Spark Platform, but do not have a use case to access any of their data, consider the OpenId authentication flow in lieu of API Authentication or the Combined flow.

Read more about Spark Platform's OpenId flow <a href="http://sparkplatform.com/docs/authentication/openid_authentication">here</a>.
