module SparkApi
  module Configuration

    begin
      require 'yajl'
      MultiJson.engine = "yajl"
    rescue LoadError => e
      # Using pure ruby JSON parser
    end
    
    # valid configuration options
    VALID_OPTION_KEYS = [:api_key, :api_secret, :api_user, :endpoint, 
      :user_agent, :version, :ssl, :ssl_verify, :oauth2_provider, :authentication_mode, 
      :auth_endpoint, :callback, :compress, :timeout, :middleware, :dictionary_version, :request_id_chain, :user_ip_address].freeze
    OAUTH2_KEYS = [:authorization_uri, :access_uri, :client_id, :client_secret,
      # Requirements for authorization_code grant type
      :redirect_uri,  
      # Requirements for password grant type
      :username, :password,
      # Requirements for single session keys
      :access_token,
      :sparkbar_uri
    ]
      
    require File.expand_path('../configuration/yaml', __FILE__)
    require File.expand_path('../configuration/oauth2_configurable', __FILE__)

    include OAuth2Configurable
    
    DEFAULT_API_KEY = nil
    DEFAULT_API_SECRET = nil
    DEFAULT_API_USER = nil
    DEFAULT_ENDPOINT = 'https://api.sparkapi.com'
    DEFAULT_REDIRECT_URI = "https://sparkplatform.com/oauth2/callback"
    DEFAULT_AUTH_ENDPOINT = 'https://sparkplatform.com/openid'  # Ignored for Spark API Auth
    DEFAULT_AUTHORIZATION_URI = 'https://sparkplatform.com/oauth2'
    DEFAULT_VERSION = 'v1'
    DEFAULT_ACCESS_URI = "#{DEFAULT_ENDPOINT}/#{DEFAULT_VERSION}/oauth2/grant"
    DEFAULT_SESSION_PATH = "/#{DEFAULT_VERSION}/session"
    DEFAULT_USER_AGENT = "Spark API Ruby Gem #{VERSION}"
    DEFAULT_SSL = true
    DEFAULT_SSL_VERIFY = true
    DEFAULT_OAUTH2 = nil
    DEFAULT_COMPRESS = false
    DEFAULT_TIMEOUT = 5 # seconds
    DEFAULT_MIDDLEWARE = 'spark_api'
    DEFAULT_DICTIONARY_VERSION = nil
    DEFAULT_REQUEST_ID_CHAIN = nil
    DEFAULT_USER_IP_ADDRESS = nil
    
    X_SPARK_API_USER_AGENT = "X-SparkApi-User-Agent"
    X_USER_IP_ADDRESS = "X-User-IP-Address"

    attr_accessor *VALID_OPTION_KEYS
    def configure
      yield(self)
      oauthify! if convert_to_oauth2?
    end

    def self.extended(base)
      base.reset_configuration
    end

    def options
      VALID_OPTION_KEYS.inject({}) do |opt,key|
        opt.merge(key => send(key))
      end
    end

    def reset_configuration
      self.api_key     = DEFAULT_API_KEY
      self.api_secret  = DEFAULT_API_SECRET
      self.api_user    = DEFAULT_API_USER
      self.authentication_mode = SparkApi::Authentication::ApiAuth
      self.auth_endpoint  = DEFAULT_AUTH_ENDPOINT
      self.endpoint    = DEFAULT_ENDPOINT
      self.oauth2_provider = DEFAULT_OAUTH2
      self.user_agent  = DEFAULT_USER_AGENT
      self.ssl         = DEFAULT_SSL
      self.ssl_verify  = DEFAULT_SSL_VERIFY
      self.version     = DEFAULT_VERSION
      self.compress    = DEFAULT_COMPRESS
      self.timeout     = DEFAULT_TIMEOUT
      self.middleware = DEFAULT_MIDDLEWARE
      self.dictionary_version = DEFAULT_DICTIONARY_VERSION
      self.request_id_chain = DEFAULT_REQUEST_ID_CHAIN
      self.user_ip_address = DEFAULT_USER_IP_ADDRESS
      self
    end
  end
end
