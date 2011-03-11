module FlexmlsApi
  module Configuration
    # valid configuration options
    VALID_OPTION_KEYS = [:api_key, :api_secret, :api_user, :endpoint, :user_agent, :version, :ssl].freeze

    DEFAULT_API_KEY = nil
    DEFAULT_API_SECRET = nil
    DEFAULT_API_USER = nil
    DEFAULT_ENDPOINT = 'http://api.flexmls.com'
    DEFAULT_VERSION = 'v1'
    DEFAULT_USER_AGENT = "flexmls API Ruby Gem #{VERSION}"
    DEFAULT_SSL = false

    attr_accessor *VALID_OPTION_KEYS
    def configure
      yield self
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
      self.endpoint    = DEFAULT_ENDPOINT
      self.version     = DEFAULT_VERSION
      self.user_agent  = DEFAULT_USER_AGENT
      self.ssl         = DEFAULT_SSL
      self
    end
  end
end
