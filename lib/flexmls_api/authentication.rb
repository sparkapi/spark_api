require 'openssl'
require 'faraday'
require 'faraday_middleware'
require 'yajl'
require 'date'
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
      sig = sign("#{@api_secret}ApiKey#{@api_key}")
      FlexmlsApi.logger.debug("Authenticating to #{@endpoint}")
      start_time = Time.now
      request_path = "/#{version}/session?ApiKey=#{api_key}&ApiSig=#{sig}"
      resp = connection(true).post request_path, ""
      request_time = Time.now - start_time
      FlexmlsApi.logger.info("[#{request_time}s] Api: POST #{request_path}")
      @session = Session.new(resp.body.results[0])
      FlexmlsApi.logger.debug("Authentication: #{@session.inspect}")
      @session
    end
    
    # Delete the current session
    def logout
      FlexmlsApi.logger.info("Logging out.")
      delete("/session/#{@session.auth_token}") unless @session.nil?
      @session = nil
    end

    # Active session object
    def session
      @session
    end
    
    # Builds an ordered list of key value pairs and concatenates it all as one big string.  Used 
    # specifically for signing a request.
    def build_param_string(param_hash)
      return "" if param_hash.nil?
        sorted = param_hash.sort do |a,b|
          a.to_s <=> b.to_s
        end
        params = ""
        sorted.each do |key,val|
          params += key.to_s + val.to_s
        end
        params
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
    
    # Sign a request
    def sign(sig)
      Digest::MD5.hexdigest(sig)
    end

    # Sign a request with request data.
    def sign_token(path, params = {}, post_data="")
      sign("#{@api_secret}ApiKey#{@api_key}ServicePath/#{version}#{path}#{build_param_string(params)}#{post_data}")
    end
    
  end
end
