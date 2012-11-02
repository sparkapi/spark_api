Spark API
=====================
[![Build Status](https://secure.travis-ci.org/ifightcrime/spark_api.png)](http://travis-ci.org/ifightcrime/spark_api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/ifightcrime/spark_api)

A Ruby wrapper for the Spark REST API. Loosely based on ActiveResource to provide models to interact with remote services.


Documentation
-------------
For full information on the API, see [http://sparkplatform.com/docs/overview/api](http://sparkplatform.com/docs/overview/api)


Installation
---------
    gem install spark_api

Usage Examples
------------------------

#### Ruby Script: OpenId/OAuth2 Combined Flow
    # initialize the gem with your key/secret.
    # See also: script/combined_flow_example.rb
    # api_key, api_secret, and callback are all required.
    # The following options are required:
    #  - api_key: Your client key
    #  - api_secret: Your client secret
    #  - callback: Your redirect_uri, which the end user will be redirected
    #              to after authorizing your application to access their data.
    #  - auth_endpoint: The URI to redirect the user's web browser to, in order for them to
    #                   authorize your application to access their data.
    # other options and their defaults:
    #  - endpoint:   'https://api.sparkapi.com'
    #  - version:    'v1'
    #  - ssl:        true
    #  - user_agent: 'Spark API Ruby Gem'
    SparkApi.configure do |config|
      config.authentication_mode = SparkApi::Authentication::OpenIdOAuth2Hybrid
      config.api_key      = "YOUR_CLIENT_ID"
      config.api_secret   = "YOUR_CLIENT_SECRET"
      config.callback     = "YOUR_REDIRECT_URI"
      config.auth_endpoint = "https://sparkplatform.com/openid"
      config.endpoint   = 'https://sparkapi.com'
    end

    # Code is retrieved from the method: SparkApi.client.authenticator.authorization_url
    # See script/combined_flow_example.rb for more details.


    SparkApi.client.oauth2_provider.code = "CODE_FROM_ABOVE_URI"
    SparkApi.client.authenticate

    # Alternatively, if you've already received an access token, you may
    # do the following instead of the above two lines:
    # SparkApi.client.session = SparkApi::Authentication::OAuthSession.new "access_token"=> "ACCESS_TOKEN", 
    #                            "refresh_token" => "REFRESH_TOKEN", "expires_in" => 86400

    # mixin the models so you can use them without prefix
    include SparkApi::Models

    # Grab your listings!
    my_listings = Listing.my()

#### Ruby Script: OAuth 2
    # initialize the gem with your OAuth 2 key/secret.
    # See also: script/oauth2_example.rb
    # api_key, api_secret, and callback are all required.
    # The following options are required:
    #  - api_key: Your OAuth 2 client key
    #  - api_secret: Your OAuth 2 client secret
    #  - callback: Your OAuth 2 redirect_uri, which the end user will be redirected
    #              to after authorizing your application to access their data.
    #  - auth_endpoint: The URI to redirect the user's web browser to, in order for them to
    #                   authorize your application to access their data.
    # other options and their defaults:
    #  - endpoint:   'https://api.sparkapi.com'
    #  - version:    'v1'
    #  - ssl:        true
    #  - user_agent: 'Spark API Ruby Gem'
    SparkApi.configure do |config|
      config.authentication_mode = SparkApi::Authentication::OAuth2
      config.api_key      = "YOUR_CLIENT_ID"
      config.api_secret   = "YOUR_CLIENT_SECRET"
      config.callback     = "YOUR_REDIRECT_URI"
      config.auth_endpoint = "https://sparkplatform.com/oauth2"
      config.endpoint   = 'https://sparkapi.com'
    end

    # Code is retrieved from the method. SparkApi.client.authenticator.authorization_url
    # See script/oauth2_example.rb for more details.


    SparkApi.client.oauth2_provider.code = "CODE_FROM_ABOVE_URI"
    SparkApi.client.authenticate

    # Alternatively, if you've already received an access token, you may
    # do the following instead of the above two lines:
    #SparkApi.client.session = SparkApi::Authentication::OAuthSession.new "access_token"=> "ACCESS_TOKEN", 
    #                           "refresh_token" => "REFRESH_TOKEN", "expires_in" => 86400

    # mixin the models so you can use them without prefix
    include SparkApi::Models

    # Grab your listings!
    my_listings = Listing.my()


#### Ruby Script: OpenId Only
    # initialize the gem with your key/secret.
    # api_key, api_secret, and callback are all required.
    # The following options are required:
    #  - api_key: Your client key
    #  - api_secret: Your client secret
    #  - callback: Your redirect_uri, which the end user will be redirected
    #              to after authorizing your application to access their data.
    #  - auth_endpoint: The URI to redirect the user's web browser to, in order for them to
    #                   authorize your application to access their data.
    # other options and their defaults:
    #  - user_agent: 'Spark API Ruby Gem'
    SparkApi.configure do |config|
      config.authentication_mode = SparkApi::Authentication::OpenId
      config.api_key      = "YOUR_CLIENT_ID"
      config.api_secret   = "YOUR_CLIENT_SECRET"
      config.callback     = "YOUR_REDIRECT_URI"
      config.auth_endpoint = "https://sparkplatform.com/openid"
    end

    # Code is retrieved from the method: 
    # See script/combined_flow_example.rb for more details.
    # Optionally, additional a GET parameters can be supplied as a hash to
    # authorization_url.
    # SparkApi.client.authenticator.authorization_url

    # That's it! No API Access is available when using OpenID alone.


#### Ruby Script
    # initialize the gem with your key/secret
    # api_key and _api_secret are the only required settings
    # other options and their defaults:
    #  - endpoint:   'https://api.sparkapi.com'
    #  - version:    'v1'
    #  - ssl:         false
    #  - user_agent: 'Spark API Ruby Gem'
    SparkApi.configure do |config|
        config.endpoint   = 'https://sparkapi.com'
        config.api_key    = 'my_api_key'
        config.api_secret = 'my_api_secret'
    end

    # mixin the models so you can use them without prefix
    include SparkApi::Models

    # Grab your listings!
    my_listings = Listing.my()


#### Interactive Console
Included in the gem is a simple setup script to run the client in IRB.  To use it, first create the file called _.spark_api_testing_ filling in the credentials for your account.

    API_USER="12345678901234567890123456" # 26-digit identifier of an API user
    API_ENDPOINT="https://sparkapi.com"
    API_KEY="my_api_key"
    API_SECRET="my_api_secret"

    export API_USER API_ENDPOINT API_KEY API_SECRET

Now, to run with this setup, run the following from the command line:

    > source .spark_api_testing
    > spark_api
    SparkApi> SparkApi.client.get '/my/account'

You can also provide these options from the command line, see "spark_api -h" for more information


Authentication Types
--------------
Authentication is handled transparently by the request framework in the gem, so you should never need to manually make an authentication request.  More than one mode of authentication is supported, so the client needs to be configured accordingly.

#### API Authentication (Default)
Usually supplied for a single user, this authentication mode is the simplest, and is setup as the default.  The example usage above demonstrates how to get started using this authentication mode.

#### OpenId/OAuth2 Combined Flow (Preferred)
Authorization mode the separates application and user authentication.  This mode requires the end user to be redirected to Spark Platform's openid endpoint.  See "script/combined_flow_example.rb" for an example.

Read more about Spark Platform's combined flow <a href="http://sparkplatform.com/docs/authentication/openid_oauth2_authentication">here</a>.

#### OAuth2 Authorization
Authorization mode the separates application and user authentication.  This mode requires the end user to be redirected to Spark Platform's auth endpoint.  See "script/oauth2_example.rb" for an example.

Read more about Spark Platform's OAuth 2 flow <a href="http://sparkplatform.com/docs/authentication/oauth2_authentication">here</a>.

#### OpenId Authentication
There is also the option to only access a user's Spark Platform identity without accessing any data (e.g. listings, contacts, etc.).  In circumstances where you ONLY with to authenticate users through the Spark Platform, but do not have a use case to access any of their data, consider the OpenId authentication flow in lieu of API Authentication or the Combined flow.

Read more about Spark Platform's OpenId flow <a href="http://sparkplatform.com/docs/authentication/openid_authentication">here</a>.

Error Codes
---------------------
<table>
  <thead>
    <tr>
      <th>HTTP Code</th>
      <th>Spark API Error Code</th>
      <th>Exception Raised</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>401</tt></td>
      <td><tt>1000</tt></td>
      <td><tt></tt></td>
      <td>Invalid API Key and/or Request signed improperly</td>
    </tr>
    <tr>
      <td><tt>401</tt></td>
      <td><tt>1010</tt></td>
      <td><tt></tt></td>
      <td>API key is disabled</td>
    </tr>
    <tr>
      <td><tt>403</tt></td>
      <td><tt>1015</tt></td>
      <td><tt></tt></td>
      <td><tt>ApiUser</tt> must be supplied, or the provided key does not have access to the supplied user</td>
    </tr>
    <tr>
      <td><tt>401</tt></td>
      <td><tt>1020</tt></td>
      <td><tt></tt></td>
      <td>Session token has expired</td>
    </tr>
    <tr>
      <td><tt>403</tt></td>
      <td><tt>1030</tt></td>
      <td><tt></tt></td>
      <td>SSL required for this type of request</td>
    </tr>
    <tr>
      <td><tt>400</tt></td>
      <td><tt>1035</tt></td>
      <td><tt></tt></td>
      <td>POST data not supplied as valid JSON. Issued if the <tt>Content-Type</tt> header is not <tt>application/json/</tt> and/or if the POST data is not in valid JSON format.</td>
    </tr>
    <tr>
      <td><tt>400</tt></td>
      <td><tt>1040</tt></td>
      <td><tt></tt></td>
      <td>The <tt>_filter</tt> syntax was invalid or a specified field to search on does not exist</td>
    </tr>
    <tr>
      <td><tt>400</tt></td>
      <td><tt>1050</tt></td>
      <td><tt></tt></td>
      <td>(message varies) A required parameter was not provided</td>
    </tr>
    <tr>
      <td><tt>400</tt></td>
      <td><tt>1053</tt></td>
      <td><tt></tt></td>
      <td>(message varies) A parameter was provided but does not adhere to constraints</td>
    </tr>
    <tr>
      <td><tt>409</tt></td>
      <td><tt>1055</tt></td>
      <td><tt></tt></td>
      <td>(message varies)Issued when a write is requested that will conflict with existing data. For example, adding a new contact with an e-mail that already exists.</td>
    </tr>
    <tr>
      <td><tt>403</tt></td>
      <td><tt>1500</tt></td>
      <td><tt></tt></td>
      <td>The resource is not available at the current API key's service level. For example, this error applies if a user attempts to access the IDX Links API via a free API key. </td>
    </tr>
    <tr>
      <td><tt>503</tt></td>
      <td><tt>1550</tt></td>
      <td><tt></tt></td>
      <td>Over rate limit</td>
  </tbody>
</table>

