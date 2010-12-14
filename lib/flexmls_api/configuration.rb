module FlexmlsApi
  module Configuration
    # valid configuration options
    VALID_OPTION_KEYS = [:api_key, :api_secret, :endpoint, :user_agent, :version].freeze

    DEFAULT_API_KEY = nil
    DEFAULT_API_SECRET = nil
    DEFAULT_ENDPOINT = 'api.flexmls.com'
    DEFAULT_VERSION = 'v1'
    DEFAULT_USER_AGENT = "flexmls API Ruby Gem PUTVERSIONHERE"

    attr_accessor *VALID_OPTION_KEYS
    def configure
      yield self
      puts "Inspect: #{self.inspect}"
    end

    def self.extended(base)
      base.reset
    end

    def show_settings
      puts "Settings:"
      puts "========================"
      puts "ApiKey:      #{self.api_key}"
      puts "ApiSecret:   #{self.api_secret}"
      puts "Endpoint:    #{self.endpoint}"
      puts "Version:     #{self.version}"
      puts "UA:          #{self.user_agent}"

    end

    def options
      VALID_OPTION_KEYS.inject({}) do |opt,key|
        opt.merge(key => send(key))
      end
    end


    def reset
      puts "============Called Reset============"
      self.api_key     = DEFAULT_API_KEY
      self.api_secret  = DEFAULT_API_SECRET
      self.endpoint    = DEFAULT_ENDPOINT
      self.version     = DEFAULT_VERSION
      self.user_agent  = DEFAULT_USER_AGENT
      puts show_settings
      self
    end
  end
end
