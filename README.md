flexmls API
=====================
A Ruby wrapper for the flexmls REST API. Loosely based on ActiveResource to provide models to interact with remote services.


Documentation
-------------
For full information on the API, see http://documentation-url-goes-here.com 


Installation
---------
    gem install flexmls_api4r

Usage Examples
------------------------
    # initialize the gem with your key/secret
    # api_key and _api_secret are the only required settings
    # other options and their defaults:
    #  - endpoint:   'http://api.flexmls.com'  
    #  - version:    'v1'
    #  - ssl:         false
    #  - user_agent: 'flexmls API Ruby Gem'
    FlexmlsApi.configure do |config|
        config.api_key    = 'your_api_key'
        config.api_secret = 'your_api_secret'
    end

    # mixin the models so you can use them without prefix
    include FlexmlsApi::Models

    # Grab your listings!
    my_listings = Listing.my()

Authentication
--------------
Authentication is handled transparently by the request framework in the gem, so you should never need to manually make an authentication request.



Error Codes
---------------------
<table>
  <thead>
    <tr>
      <th>HTTP Code</th>
      <th>flexmls API Error Code</th>
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



