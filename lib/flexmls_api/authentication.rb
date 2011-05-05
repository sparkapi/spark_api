
require 'openssl'
require 'faraday'
require 'faraday_middleware'
require 'yajl'
require 'date'

require File.expand_path('../authentication/base_auth', __FILE__)
require File.expand_path('../authentication/api_auth', __FILE__)
require File.expand_path('../authentication/oauth2', __FILE__)

module FlexmlsApi
  # =Authentication
  # Mixin module for handling client authentication and reauthentication to the flexmls api.  Makes 
  # use of the configured authentication mode (API Auth by default).
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
      new_session = @authenticator.authenticate
      FlexmlsApi.logger.info("[#{(request_time * 1000).to_i}ms]")
      FlexmlsApi.logger.debug("Session: #{new_session.inspect}")
      new_session
    end

    # Test to see if there is an active session
    def authenticated?
      @authenticator.authenticated?
    end
    
    # Delete the current session
    def logout
      FlexmlsApi.logger.info("Logging out.")
      @authenticator.logout
    end

    # Fetch the active session object
    def session
      @authenticator.session
    end
    # Save the active session object
    def session=(active_session)
      @authenticator.session=active_session
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
    
    # HTTP request headers for client requests
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
