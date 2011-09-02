module FlexmlsApi
  # =API Client
  # Main class to setup and run requests on the API.  A default client is accessible globally as 
  # FlexmlsApi::client if the global configuration has been set as well.  Otherwise, this class may 
  # be instanciated separately with the configuration information.
  class Client
    include Authentication
    include Request
    
    attr_accessor :authenticator
    attr_accessor *Configuration::VALID_OPTION_KEYS
    
    # Constructor bootstraps the client with configuration and authorization class.
    # options - see Configuration::VALID_OPTION_KEYS
    # auth_klass - subclass of Authentication::BaseAuth Defaults to the original api auth system.
    def initialize(options={}, auth_klass=ApiAuth)
      options = FlexmlsApi.options.merge(options)
      Configuration::VALID_OPTION_KEYS.each do |key|
        send("#{key}=", options[key])
      end
      # Instanciate the authenication class passed in.
      @authenticator = authentication_mode.send("new", self)
    end
    
  end
end
