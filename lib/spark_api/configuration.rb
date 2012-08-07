module SparkApi
  module Configuration

    MultiJson.engine = "yajl"
    
    # valid configuration options
    VALID_OPTION_KEYS = [:api_key, :api_secret, :api_user, :endpoint, 
      :user_agent, :version, :ssl, :oauth2_provider, :authentication_mode, 
      :auth_endpoint, :callback].freeze
    OAUTH2_KEYS = [:authorization_uri, :access_uri, :client_id, :client_secret,
      # Requirements for authorization_code grant type
      :redirect_uri,  
      # Requirements for password grant type
      :username, :password
    ]
      
    require File.expand_path('../configuration/yaml', __FILE__)
    require File.expand_path('../configuration/oauth2_configurable', __FILE__)

    include OAuth2Configurable
    
    DEFAULT_API_KEY = nil
    DEFAULT_API_SECRET = nil
    DEFAULT_API_USER = nil
    DEFAULT_ENDPOINT = 'https://api.sparkapi.com'
    DEFAULT_AUTH_ENDPOINT = 'https://sparkplatform.com/openid'  # Ignored for Spark API Auth
    DEFAULT_VERSION = 'v1'
    DEFAULT_USER_AGENT = "Spark API Ruby Gem #{VERSION}"
    DEFAULT_SSL = true
    DEFAULT_OAUTH2 = nil
    
    X_SPARK_API_USER_AGENT = "X-SparkApi-User-Agent"

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
      self.version     = DEFAULT_VERSION
      self
    end
  end
end
