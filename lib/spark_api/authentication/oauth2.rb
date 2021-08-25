require 'uri'

module SparkApi

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
      
      def initialize(client)
        super(client)
        @provider = client.oauth2_provider
      end
      
      def session
        @provider.load_session()
      end
      def session=(s)
        @provider.save_session(s)
      end
      
      def authenticate
        granter = OAuth2Impl::GrantTypeBase.create(@client, @provider, session)
        self.session = granter.authenticate
        session
      end
      
      # Perform an HTTP request (no data)
      def request(method, path, body, options={})
        escaped_path = Addressable::URI.escape(path)
        connection = @client.connection(true)  # SSL Only!
        connection.headers.merge!(options.delete(:override_headers) || {})
        connection.headers.merge!(self.auth_header)

        unless (@client.api_user.nil? || options[:ApiUser])
          options.merge!(:ApiUser => "#{@client.api_user}")
        end

        parameter_string = options.size > 0 ? "?#{build_url_parameters(options)}" : ""
        request_path = "#{escaped_path}#{parameter_string}"
        SparkApi.logger.debug { "Request: #{request_path}" }
        if body.nil?
          response = connection.send(method, request_path)
        else
          SparkApi.logger.debug { "Data: #{body}" }
          response = connection.send(method, request_path, body)
        end
        response
      end
      
      def logout
        @provider.save_session(nil)
      end
      
      def authorization_url()
        params = {
          "client_id" => @provider.client_id,
          "response_type" => "code",
          "redirect_uri" => @provider.redirect_uri
        }
        "#{@provider.authorization_uri}?#{build_url_parameters(params)}"
      end
      
      # Create a sparkbar token based on the current user's access token
      def sparkbar_token()
        raise ClientError, "OAuth2Provider must configure the sparkbar_uri to use sparkbar tokens" if provider.sparkbar_uri.nil?
        SparkApi.logger.debug { "[sparkbar] create token to #{provider.sparkbar_uri}" }
        uri = URI.parse(provider.sparkbar_uri)
        request_path = "#{uri.path}"
        
        SparkApi.logger.info { "[sparkbar] create token to #{request_path}, #{session.access_token.inspect}" }
        response = sparkbar_connection("#{uri.scheme}://#{uri.host}").post(request_path, "access_token=#{session.access_token}").body
        token = response["token"]
        SparkApi.logger.debug { "[sparkbar] New token created #{token}" }
        token
      end
      
      protected
      
      attr_reader :provider, :client
      
      def auth_header
        {"Authorization"=> "OAuth #{session.access_token}"}
      end
      
      # Faraday handle to the sparkbar
      def sparkbar_connection(endpoint)
        opts = {
          :headers => client.headers
        }
        opts[:headers].delete(:content_type)
        opts[:ssl] = {:verify => false } unless @client.ssl_verify
        opts[:url] = endpoint       
        conn = Faraday::Connection.new(opts) do |conn|
          conn.response :sparkbar_impl
          conn.adapter Faraday.default_adapter
        end
      end        

    end

    #==OpenId/OAuth 2 Hybrid
    # Uses OpenId for Authentication, but also uses OAuth2 for authorization.
    class OpenIdOAuth2Hybrid < OAuth2
      def authorization_url(parameters={})
        params = openid_parameters.merge(parameters)
        params["openid.spark.combined_flow"] = true
        build_openid_uri(params)
      end

      protected

      def build_openid_uri(params)
        "#{@provider.authorization_uri}?#{build_url_parameters(params)}"
      end

      def openid_parameters
        {
          "openid.mode" => "checkid_setup",
          "openid.spark.client_id" => @provider.client_id,
          "openid.return_to" => @provider.redirect_uri
        }
      end
    end

    class OpenId < OpenIdOAuth2Hybrid
      def authorization_url(parameters={})
        params = openid_parameters.merge(parameters)
        build_openid_uri(params)
      end

      def authenticate
        raise RuntimeError, "API Authorization not available with an OpenId-only Auth instance"
      end
      
      def request(method, path, body, options={})
        raise RuntimeError, "API Data not available with an OpenId-only Auth instance"
      end
    end
    
    # Representation of a session with the api using oauth2
    class OAuthSession
      SESSION_ATTRIBUTES = [:access_token, :expires_in, :scope, :refresh_token, :refresh_timeout, :start_time]
      attr_accessor *SESSION_ATTRIBUTES
      def initialize(o={})

        options = OptionsHash.new(o)

        @access_token = options["access_token"]
        @expires_in = options["expires_in"]
        @scope = options["scope"]
        @refresh_token = options["refresh_token"]
        @start_time = options.fetch("start_time", DateTime.now)
        @refresh_timeout = options.fetch("refresh_timeout", 43200)
        if @start_time.is_a? String
          @start_time = DateTime.parse(@start_time)
        end
      end
      #  Is the user session token expired?
      def expired?
        return false if @expires_in.nil?
        @start_time + Rational(@expires_in - @refresh_timeout, 86400) < DateTime.now
      end
      
      def to_json(*a)
        to_hash.to_json(*a)
      end
      
      def to_hash
        hash = {}
        SESSION_ATTRIBUTES.each do |k|
          value = self.send(k)
          hash[k.to_s] = value unless value.nil?
        end
        hash 
      end
    end
    
    #=OAuth2 configuration provider for applications
    # Applications planning to use OAuth2 authentication with the API must extend this class as 
    # part of the client configuration, providing values for the following attributes:
    #  @authorization_uri - User oauth2 login page for the Spark platform
    #  @access_uri - Location of the OAuth2 access token resource for the api.  OAuth2 code and 
    #    credentials will be sent to this uri to generate an access token.
    #  @redirect_uri - Application uri to redirect to 
    #  @client_id - OAuth2 provided application identifier
    #  @client_secret - OAuth2 provided password for the client id
    class BaseOAuth2Provider
      attr_accessor *Configuration::OAUTH2_KEYS
      # Requirements for authorization_code grant type
      attr_accessor :code
      attr_accessor :grant_type
      
      def initialize(opts={})
        Configuration::OAUTH2_KEYS.each do |key|
          send("#{key}=", opts[key]) if opts.include? key
        end
        @grant_type = :authorization_code
      end
      
      def grant_type
        # backwards compatibility check
        @grant_type.nil? ?  :authorization_code : @grant_type
      end
      
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
        86400 # 1.day
      end

    end

    module OAuth2Impl
      require 'spark_api/authentication/oauth2_impl/faraday_middleware'
      require 'spark_api/authentication/oauth2_impl/grant_type_base'
      require 'spark_api/authentication/oauth2_impl/grant_type_refresh'
      require 'spark_api/authentication/oauth2_impl/grant_type_code'
      require 'spark_api/authentication/oauth2_impl/grant_type_password'
      require 'spark_api/authentication/oauth2_impl/cli_provider'
      require 'spark_api/authentication/oauth2_impl/simple_provider'
      require 'spark_api/authentication/oauth2_impl/single_session_provider'
      
      # Loads a provider class from a string
      def self.load_provider(string, args={})
        constant = Object
        string.split("::").compact.each { |name| constant = constant.const_get(name) unless name == ""}
        constant.new(args)
      rescue => e
        raise ArgumentError, "The value '#{string}' is an invalid class name for an oauth2 provider:  #{e.message}"
      end
    end
    
  end
 
end
