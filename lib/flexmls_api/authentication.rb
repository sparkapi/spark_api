
require 'openssl'
require 'faraday'
require 'faraday_middleware'
require 'yajl'
require 'date'

require File.expand_path('../authentication/base_auth', __FILE__)
require File.expand_path('../authentication/api_auth', __FILE__)
require File.expand_path('../authentication/oauth2', __FILE__)

module FlexmlsApi
  # =API Authentication
  # Handles authentication and reauthentication to the flexmls api.
  module Authentication

    # Main authentication step.  Run before any api request unless the user session exists and is 
    # still valid.
    #
    # *returns*
    #   The user session object when authentication succeeds
    # *raises*
    #   FlexmlsApi::ClientError when authentication fails
    def authenticate
      start_time = Time.now
      request_time = Time.now - start_time
      newsession = @authenticator.authenticate
      FlexmlsApi.logger.info("[#{(request_time * 1000).to_i}ms]")
      FlexmlsApi.logger.debug("Session: #{session.inspect}")
      newsession
    end

    def authenticated?
      @authenticator.authenticated?
    end
    
    # Delete the current session
    def logout
      FlexmlsApi.logger.info("Logging out.")
      @authenticator.logout
    end

    # Active session object
    def session
      @authenticator.session
    end
    
    def session=(s)
      @authenticator.session=s
    end
    
    # ==Session class
    # Handle on the api user session information as return by the api session service, including 
    # roles, tokens and expiration
    class Session
      attr_accessor :auth_token, :expires, :roles 
      def initialize(options={})
        @auth_token = options["AuthToken"]
        @expires = DateTime.parse options["Expires"]
        @roles = options["Roles"]
      end
      #  Is the user session token expired?
      def expired?
        DateTime.now > @expires
      end
    end
    
    # Main connection object for running requests.  Bootstraps the Faraday abstraction layer with 
    # our client configuration.
    def connection(force_ssl = false)
      opts = {
        :headers => headers
      }
      domain = @endpoint 
      if(force_ssl || self.ssl)
        opts[:ssl] = {:verify => false }
        opts[:url] = @endpoint.sub /^http:/, "https:"
      else 
        opts[:url] = @endpoint.sub /^https:/, "http:"
      end
      conn = Faraday::Connection.new(opts) do |builder|
        builder.adapter Faraday.default_adapter
        builder.use Faraday::Response::ParseJson
        builder.use FlexmlsApi::FaradayExt::FlexmlsMiddleware
      end
      FlexmlsApi.logger.debug("Connection: #{conn.inspect}")
      conn
    end
    
    # HTTP request headers
    def headers
      {
        :accept => 'application/json',
        :content_type => 'application/json',
        :user_agent => user_agent,
        'X-flexmlsApi-User-Agent' => user_agent
      }
    end
    
  end
end
