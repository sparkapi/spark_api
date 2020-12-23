module SparkApi
  # =API Client
  # Main class to setup and run requests on the API.  A default client is accessible globally as 
  # SparkApi::client if the global configuration has been set as well.  Otherwise, this class may 
  # be instantiated separately with the configuration information.
  class Client
    include Connection
    include Authentication
    include Request

    require File.expand_path('../configuration/oauth2_configurable', __FILE__)
    include Configuration::OAuth2Configurable
    
    attr_accessor :authenticator
    attr_accessor *Configuration::VALID_OPTION_KEYS
    
    # Constructor bootstraps the client with configuration and authorization class.
    # options - see Configuration::VALID_OPTION_KEYS
    def initialize(options={})
      options = SparkApi.options.merge(options)
      Configuration::VALID_OPTION_KEYS.each do |key|
        send("#{key}=", options[key])
      end
      # Instantiate the authentication class passed in.
      @authenticator = authentication_mode.send("new", self)
    end
    
  end
end
