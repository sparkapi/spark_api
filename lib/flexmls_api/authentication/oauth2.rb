require 'uri'

module FlexmlsApi

  module Authentication
    #=OAuth2 Authentication
    # Auth implementation to the API using the OAuth2 service endpoint.  Current adheres to the 10 
    # draft of the OAuth2 specification.  With OAuth2, the application supplies credentials for the 
    # application, and a separate a user authentication flow dictactes the active user for 
    # requests.
    #
    #===Setup
    # When using this authentication method, there is a bit more setup involved to make the client
    # work.  All applications need to extend the BaseOAuth2Provider class to supply the application
    # specific configuration.  Also depending on the application type (command line, native, or web 
    # based), the user authentication step will be handled differently.
    
    #==OAuth2
    # Implementation the BaseAuth interface for API style authentication  
    class OAuth2 < BaseAuth
      
      def session
        @provider.load_session()
      end
      def session=(s)
        @provider.save_session(s)
      end
      
      def initialize(client)
        @client = client
        @provider = client.oauth2_provider
      end
      
      # Generate the appropriate request uri for authorizing this application for current user.
      def authorization_url
        params = {
          "client_id" => @provider.client_id,
          "response_type" => "code",
          "redirect_uri" => @provider.redirect_uri
        }
        "#{@provider.authorization_uri}?#{build_url_parameters(params)}"
      end
      
      def token_params
        params = {
          "client_id" => @provider.client_id,
          "client_secret" => @provider.client_secret,
          "grant_type" => "authorization_code",
          "code" => @provider.code,
          "redirect_uri" => @provider.redirect_uri
        }
       params.to_json 
      end
      
      def authenticate
        if(@provider.code.nil?)
          FlexmlsApi.logger.debug("Redirecting to provider to get the authorization code")
          @provider.redirect(authorization_url)
        end
        FlexmlsApi.logger.debug("Authenticating to #{@provider.access_uri}")
        uri = URI.parse(@provider.access_uri)
        request_path = "#{uri.path}"
        response = oauth_access_connection("#{uri.scheme}://#{uri.host}").post(request_path, "#{token_params}").body
        response.expires_in = @provider.session_timeout if response.expires_in.nil?
        self.session=response
        response
      end
      
      # Perform an HTTP request (no data)
      def request(method, path, body, options)
        escaped_path = URI.escape(path)
        connection = @client.connection(true)  # SSL Only!
        connection.headers.merge!(self.auth_header)
        request_opts = {}
        request_opts.merge!(options)
        request_path = "#{escaped_path}?#{build_url_parameters({:access_token => session.access_token}.merge(options))}"
        FlexmlsApi.logger.debug("Request: #{request_path}")
        if body.nil?
          response = connection.send(method, request_path)
        else
          FlexmlsApi.logger.debug("Data: #{body}")
          response = connection.send(method, request_path, body)
        end
        response
      end
      
      def logout
        @provider.save_session(nil)
      end

            
      protected
      
      def auth_header
        {"Authorization"=> "OAuth #{session.access_token}"}
      end
      
      # Setup a faraday connection for dealing with an OAuth2 endpoint
      def oauth_access_connection(endpoint)
        opts = {
          :headers => @client.headers
        }
        opts[:ssl] = {:verify => false }
        opts[:url] = endpoint       
        conn = Faraday::Connection.new(opts) do |builder|
          builder.adapter Faraday.default_adapter
          builder.use Faraday::Response::ParseJson
          builder.use FlexmlsApi::Authentication::FlexmlsOAuth2Middleware
        end
      end
    end
    
    # Representation of a session with the api using oauth2
    class OAuthSession
      attr_accessor :access_token, :expires_in, :scope, :refresh_token
      def initialize(options={})
        @access_token = options["access_token"]
        # TODO The current oauth2 service does not send an expiration time.  I'm setting it to default to 1 hour.
        @expires_in = options["expires_in"]
        @scope = options["scope"]
        @refresh_token = options["refresh_token"]
        @start_time = DateTime.now
      end
      #  Is the user session token expired?
      def expired?
        @start_time + Rational(@expires_in, 24*60*60) < DateTime.now
      end
    end
    
    #=OAuth2 configuration provider for applications
    # Applications planning to use OAuth2 authentication with the API must extend this class as 
    # part of the client configuration, providing values for the following attributes:
    #  @authorization_uri - User oauth2 login page for flexmls
    #  @access_uri - Location of the OAuth2 access token resource for the api.  OAuth2 code and 
    #    credentials will be sent to this uri to generate an access token.
    #  @redirect_uri - Application uri to redirect to 
    #  @client_id - OAuth2 provided application identifier
    #  @client_secret - OAuth2 provided password for the client id
    class BaseOAuth2Provider
      
      attr_accessor :authorization_uri, :code, :access_uri, :redirect_uri, :client_id, :client_secret

      # Application using the client must handle user redirect for user authentication.  For 
      # command line applications, this method is called prior to initial client requests so that  
      # the process can notify the user to go to the url and retrieve the access_code for the app.  
      # In a web based web application, this method can be mostly ignored.  However, the web based 
      # application is then responsible for ensuring the code is saved to the the provider instance  
      # prior to any client requests are performed (or the error below will be thrown). 
      def redirect(url)
        raise "To be implemented by client application"
      end
      
      #==For any persistence to be supported outside application process, the application shall 
      # implement the following methods for storing and retrieving the user OAuth2 session 
      # (e.g. to and from memcached).
      
      # Load the current OAuth session
      # returns - active OAuthSession or nil
      def load_session
        nil
      end
      
      # Save current session
      # session - active OAuthSession
      def save_session(session)
        
      end
      
      # Provides a default session time out
      # returns - the session timeout length (in seconds)
      def session_timeout
        3600
      end
      
    end

    #==OAuth2 Faraday response middleware
    # HTTP Response after filter to package oauth2 responses and bubble up basic api errors.
    class FlexmlsOAuth2Middleware < Faraday::Response::Middleware
      begin
        def self.register_on_complete(env)
          env[:response].on_complete do |finished_env|
            validate_and_build_response(finished_env)
          end
        end
      rescue LoadError, NameError => e
        self.load_error = e
      end
      
      def self.validate_and_build_response(finished_env)
        body = finished_env[:body]
        FlexmlsApi.logger.debug("Response Body: #{body.inspect}")
        unless body.is_a?(Hash)
          raise InvalidResponse, "The server response could not be understood"
        end
        case finished_env[:status]
        when 200..299
          FlexmlsApi.logger.debug("Success!")
          session = OAuthSession.new(body)
        else 
          # Handle the WWW-Authenticate Response Header Field if present. This can be returned by 
          # OAuth2 implementations and wouldn't hurt to log.
          auth_header_error = finished_env[:request_headers]["WWW-Authenticate"]
          FlexmlsApi.logger.warn("Authentication error #{auth_header_error}") unless auth_header_error.nil?
          raise ClientError.new(0, finished_env[:status]), body["error"]
        end
        FlexmlsApi.logger.debug("Session= #{session.inspect}")
        finished_env[:body] = session
      end
  
      def initialize(app)
        super
        @parser = nil
      end
      
    end
    
  end
 
end
